//
//  IAPManager.swift
//  SuperWindow
//
//  Created by Joe Manto on 9/26/21.
//

import Foundation
import StoreKit

enum Product: String, CaseIterable {
    case FullAccess = "com.joemanto.superwindow.purchases.fullaccess"
}

enum IAPManagerMessage: String, CaseIterable {
    case processedAllRestorable
    case restoredPurchases
    case errorRestoringPurchases
    case transactionFailed
    case cantMakePurchases
    case purchasedItem
}

protocol IAPManagerDelegate: AnyObject {
    func didReceiveMessage(_ message: IAPManagerMessage, errorMsg: String?)
}

final class IAPManager: NSObject {
    
    static let shared = IAPManager()
    
    weak var delegate: IAPManagerDelegate?
    var products: [SKProduct] = []
    
    var isAuthorizedForPayments: Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    func fetchProducts() {
        let request = SKProductsRequest(
            productIdentifiers: Set(Product.allCases.compactMap({ $0.rawValue }))
        )
        request.delegate = self
        request.start()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        for product in response.products {
            print(product.price)
        }
        self.products = response.products
    }
    
    func purchase(_ product: Product) {
        guard SKPaymentQueue.canMakePayments() else {
            Logging.shared.log(msg: "Not Authorized To Make Payments", comp: "[IAPManager]", type: .warn)
            self.delegate?.didReceiveMessage(.cantMakePurchases, errorMsg: "")
            return
        }
        
        guard let storeKitProduct = products.first(where: {$0.productIdentifier == product.rawValue }) else {
            Logging.shared.log(msg: "Unable get product from products array", comp: "[IAPManager]", type: .err)
            return
        }
        
        let paymentRequest = SKPayment(product: storeKitProduct)
        SKPaymentQueue.default().add(paymentRequest)
    }
    
    func restore() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    private func handlePurchased(_ transaction: SKPaymentTransaction) {
        let productId = transaction.payment.productIdentifier
        Logging.shared.log(msg: "Purchased \(productId)", comp: "[IAPManager]")
        Settings.shared.setValue(1, forKey: productId, log: true)
        self.delegate?.didReceiveMessage(.purchasedItem, errorMsg: "")
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func handleRestored(_ transaction: SKPaymentTransaction) {
        Logging.shared.log(msg: "Restored \(transaction.payment.productIdentifier)", comp: "[IAPManager]")
        Settings.shared.setValue(1, forKey: transaction.payment.productIdentifier, log: true)
        self.delegate?.didReceiveMessage(.restoredPurchases, errorMsg: "")
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func handleFailed(_ transaction: SKPaymentTransaction) {
        if let error = transaction.error as? SKError {
            Logging.shared.log(msg: """
                Failed payment on productId: \(transaction.payment.productIdentifier) error: \(error.localizedDescription)
            """, comp: "[IAPManager]")
            
            if error.code != .paymentCancelled {
                self.delegate?.didReceiveMessage(.transactionFailed, errorMsg: error.localizedDescription)
            }
        }
        
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func handleUnknown(_ transaction: SKPaymentTransaction) {
        Logging.shared.log(msg: "Unknown payment transaction", comp: "[IAPManager]")
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        Logging.shared.log(msg: "Completed restoring \(queue.transactions.count) transactions", comp: "[IAPManager]")
    }
}

extension IAPManager: SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
                case .purchasing:
                    Logging.shared.log(msg: "Purchasing", comp: "[IAPManager]")
                    break
                case .deferred:
                    Logging.shared.log(msg: "Deferred Purchase", comp: "[IAPManager]")
                    break
                case .purchased:
                    handlePurchased(transaction)
                    break
                case .restored:
                    handleRestored(transaction)
                    break
                case .failed:
                    handleFailed(transaction)
                    break
                @unknown default:
                    handleUnknown(transaction)
                    continue
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        Logging.shared.log(msg: "Error during restoring completed transacations error: \(error.localizedDescription)", comp: "[IAPManager]", type: .err)
        if let error = error as? SKError, error.code != .paymentCancelled {
            DispatchQueue.main.async {
                self.delegate?.didReceiveMessage(.errorRestoringPurchases, errorMsg: error.localizedDescription)
            }
        }
    }
    
    /// Called when a transcation has finished. Logs all transactions that have been removed from the payment queue.
    func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            Logging.shared.log(msg: "Transaction \(transaction.payment.productIdentifier) finished", comp: "[IAPManager]")
        }
    }
}
