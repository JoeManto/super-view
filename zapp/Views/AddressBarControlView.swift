//
//  AddressControlView.swift
//  SuperWindow
//
//  Created by Joe Manto on 11/23/21.
//

import Foundation
import AppKit

enum WebViewDirectionOption {
    case forward, backward
}

class AddressBarControlViewModel {
    
    private let directions: [WebViewDirectionOption]
    
    init(directions: [WebViewDirectionOption] = []) {
        self.directions = directions
    }
    
    func canGoForward() -> Bool {
        return directions.contains(.forward)
    }
    
    func canGoBackwards() -> Bool {
        return directions.contains(.backward)
    }
}

class AddressBarControlView: NSView {
    private(set) var forwardBtn: NSButton!
    private(set) var backBtn: NSButton!
    var model: AddressBarControlViewModel
    
    required init(model: AddressBarControlViewModel = AddressBarControlViewModel()) {
        self.model = model
        super.init(frame: .zero)
        self.setUpView()
    }
    
    private func setUpView() {
        let backImage = NSImage(named: NSImage.goBackTemplateName) ?? NSImage()
        let fowardImage = NSImage(named: NSImage.goForwardTemplateName) ?? NSImage()
        
        self.forwardBtn = NSButton(image: fowardImage, target: self, action: #selector(self.forwardBtn(_:)))
        self.forwardBtn.translatesAutoresizingMaskIntoConstraints = false
        self.backBtn = NSButton(image: backImage, target: self, action: #selector(self.backBtn(_:)))
        self.backBtn.translatesAutoresizingMaskIntoConstraints = false
        self.updateView(model: self.model)
        
        self.addSubview(forwardBtn)
        self.addSubview(backBtn)
        
        NSLayoutConstraint.activate([
            self.forwardBtn.leadingAnchor.constraint(equalTo: self.backBtn.trailingAnchor, constant: 10.0),
            self.backBtn.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.forwardBtn.rightAnchor.constraint(equalTo: self.rightAnchor),
            self.backBtn.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.forwardBtn.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
    }
    
    func updateView(model: AddressBarControlViewModel) {
        self.model = model
        self.forwardBtn.isEnabled = model.canGoForward()
        self.backBtn.isEnabled = model.canGoBackwards()
    }
    
    @objc func forwardBtn(_ sender: NSButton) {
        guard let windowId = self.window?.identifier?.rawValue else {
            Logging.shared.log(msg: "Unable send notification without window Id", comp: "[AddressBarControlView]", type: .err)
            return
        }
        
        NotificationCenter.default.post(name: Notification.WebViewDirectionChange(windowId: windowId), object: self, userInfo: [
            "direction": WebViewDirectionOption.forward
        ])
    }
    
    @objc func backBtn(_ sender: NSButton) {
        guard let windowId = self.window?.identifier?.rawValue else {
            Logging.shared.log(msg: "Unable send notification without window Id", comp: "[AddressBarControlView]", type: .err)
            return
        }
        
        NotificationCenter.default.post(name: Notification.WebViewDirectionChange(windowId: windowId), object: self, userInfo: [
            "direction": WebViewDirectionOption.backward
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
