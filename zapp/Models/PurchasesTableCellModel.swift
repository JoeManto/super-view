//
//  PurchasesTableCellModel.swift
//  SuperWindow
//
//  Created by Joe Manto on 9/26/21.
//

import Foundation
import StoreKit

extension SKProduct {
    /// - returns: The cost of the product formatted in the local currency.
    var regularPrice: String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = self.priceLocale
        return formatter.string(from: self.price)
    }
}

struct PurchasesTableCellModel {
    var product: SKProduct
    var isPurchased: Bool
    
    func getProductTitle() -> String {
        var title = self.product.localizedTitle
        let productPriceString = self.getProductPrice()
        
        if title.count == 0 {
            Logging.shared.log(msg: "Wasn't able to get localized title", comp: "[PurchasesTableCellModel]", type: .err)
            title = getDefaultProductTitle(for: product.productIdentifier)
        }
        
        return "\(title) - \(productPriceString)"
    }
    
    func getProductSubtitle() -> String {
        let subTitle = self.product.localizedDescription
    
        guard subTitle.count > 0 else {
            Logging.shared.log(msg: "Wasn't able to get localized description", comp: "[PurchasesTableCellModel]", type: .err)
            return getDefaultProductSubTitle(for: product.productIdentifier)
        }
        
        return subTitle
    }
    
    func getProductPrice() -> String {        
        if let price = self.product.regularPrice {
            return price
        }
        
        let localSymbol: String = {
            guard let symbol = self.product.priceLocale.currencySymbol else {
                Logging.shared.log(msg: "No price locale defaulting to USD")
                Util.showAlert(msg: "No price locale found - Showing prices in USD")
                return "$"
            }
            return symbol
        }()
        let priceString = self.product.price.description(withLocale: self.product.priceLocale)
        
        return "\(localSymbol)\(priceString)"
    }
    
    func getDefaultProductTitle(for productId: String) -> String {
        let id = Product(rawValue: productId)
        switch id {
            case .FullAccess:
                return "Full Access"
            case .none:
                return "Unknown"
        }
    }
    
    func getDefaultProductSubTitle(for productId: String) -> String {
        let id = Product(rawValue: productId)
        switch id {
            case .FullAccess:
                return "Grants unlimited usage"
            case .none:
                return "Unknown"
        }
    }
    
    func getDefaultProductPrice(for productId: String) -> String {
        let id = Product(rawValue: productId)
        switch id {
            case .FullAccess:
                return "1.99"
            case .none:
                return "Unknown"
        }
    }
}
