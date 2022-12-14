//
//  PurchasesTableCell.swift
//  SuperWindow
//
//  Created by Joe Manto on 9/26/21.
//

import Foundation

protocol PurchasesTableCellDelegate : AnyObject {
    func didHitPurchaseButton(_ sender: NSButton, model: PurchasesTableCellModel)
}

class PurchasesTableCell : NSTableCellView {
    
    weak var delegate: PurchasesTableCellDelegate?
    var model: PurchasesTableCellModel
    
    lazy var title: NSTextField = {
        let text = NSTextField()
        text.stringValue = model.getProductTitle()
        text.font = NSFont.preferredFont(forTextStyle: .largeTitle, options: [:])
        text.drawsBackground = false
        text.textColor = NSColor.textColorPrimary
        text.isBordered = false
        text.isEditable = false
        text.isSelectable = false
        text.translatesAutoresizingMaskIntoConstraints = false
        return text
    }()
    
    lazy var subTitle: NSTextField = {
        let subTitle = NSTextField()
        subTitle.stringValue = model.getProductSubtitle()
        subTitle.font = NSFont.preferredFont(forTextStyle: .subheadline, options: [:])
        subTitle.textColor = NSColor.secondaryTextColor
        subTitle.drawsBackground = false
        subTitle.isBordered = false
        subTitle.isEditable = false
        subTitle.isSelectable = false
        subTitle.translatesAutoresizingMaskIntoConstraints = false
        return subTitle
    }()
    
    lazy var purchaseBtn: NSButton = {
        let purchaseBtn = NSButton(image: NSImage(named: "purchaseBtn")!, target: self, action: #selector(self.purchaseBtnClicked(_:)))
        purchaseBtn.isBordered = false
        purchaseBtn.layer?.backgroundColor = .clear
        purchaseBtn.translatesAutoresizingMaskIntoConstraints = false
        purchaseBtn.isEnabled = !model.isPurchased
        purchaseBtn.attributedTitle = NSAttributedString(
            string:  model.isPurchased ? "Purchased" : "Purchase",
            attributes: [
                NSAttributedString.Key.foregroundColor : NSColor.textColorPrimary,
                NSAttributedString.Key.backgroundColor : NSColor.clear,
                NSAttributedString.Key.font: NSFont.preferredFont(forTextStyle: .caption2, options: [:])
            ]
        )
        return purchaseBtn
    }()
    
    init(model: PurchasesTableCellModel) {
        self.model = model
        super.init(frame: .zero)
        
        self.setupViews()
        self.setupConstraints()
    }
    
    private func setupViews() {
        self.addSubview(self.title)
        self.addSubview(self.subTitle)
        self.addSubview(self.purchaseBtn)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Title constraints
            self.title.topAnchor.constraint(equalTo: self.topAnchor, constant: 25),
            self.title.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            self.title.trailingAnchor.constraint(equalTo: self.centerXAnchor),
            
            // Subtitle constraints
            self.subTitle.topAnchor.constraint(equalTo: self.title.bottomAnchor),
            self.subTitle.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            self.subTitle.trailingAnchor.constraint(equalTo: self.centerXAnchor),
            
            self.bottomAnchor.constraint(equalTo: self.subTitle.bottomAnchor, constant: 25),
            
            // Purchase Btn constraints
            self.purchaseBtn.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10),
            self.purchaseBtn.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.purchaseBtn.widthAnchor.constraint(equalToConstant: 120),
            self.purchaseBtn.heightAnchor.constraint(equalToConstant: 44),
        ])
    }
    
    @objc func purchaseBtnClicked(_ sender: NSButton) {
        self.delegate?.didHitPurchaseButton(sender, model: self.model)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
