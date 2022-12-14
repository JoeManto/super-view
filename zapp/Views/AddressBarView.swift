//
//  AddressBar.swift
//  zapp
//
//  Created by Joe Manto on 9/4/21.
//

import Foundation
import Cocoa
import WebKit

class AddressField: NSTextField {
    
    required init() {
        super.init(frame: .zero)
        self.setUpView()
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.wantsLayer = true
        self.backgroundColor = NSColor.addressBarBackground
        self.isBordered = false
        self.layer?.cornerRadius = 5
    }
    
    func setUpView() {
        self.maximumNumberOfLines = 1
        self.lineBreakMode = .byClipping
        self.placeholderString = "https://www.somewhere.com"
        self.textColor = NSColor.textColorPrimary
        self.alignment = .center
        self.isHighlighted = false
        self.refusesFirstResponder = true
    }
    
    func setUpContraints(on view: NSView) {
        guard self.isDescendant(of: view) else {
            Logging.shared.log(msg: "can't add constraints view isn't a descendant of view", comp: "[AddressField]", type: .err)
            return
        }
        
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: view.topAnchor, constant: 5),
            self.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -5),
            self.widthAnchor.constraint(greaterThanOrEqualToConstant: 500),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

enum AddressBarShowingState {
    case showingStarted
    case showingCompleted
    case hidingStarted
    case hidingCompleted
}

class AddressBarView: NSView {
    private(set) var addressField: AddressField = {
        let field = AddressField()
        return field
    }()
    
    private(set) var addressControl: AddressBarControlView = {
        let control = AddressBarControlView()
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    private var heightConstraint: NSLayoutConstraint!
    
    // Address bar starts in showing state
    private(set) var showingState: AddressBarShowingState = .showingCompleted
    
    required init() {
        super.init(frame: .zero)
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.backgroundPrimary.cgColor
        self.addressField.delegate = self
        
        self.setUpView()
    }
    
    func setUpView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(addressControl)
        self.addSubview(addressField)
        
        let horzMargin = 15.0
        NSLayoutConstraint.activate([
            addressControl.leftAnchor.constraint(equalTo: self.leftAnchor, constant: horzMargin),
            addressControl.topAnchor.constraint(equalTo: self.topAnchor),
            addressControl.heightAnchor.constraint(equalTo: self.heightAnchor)
        ])

        addressField.setUpContraints(on: self)
    }
    
    func setUpContraints(on views: [NSView]) {
        guard views.count >= 2,
              self.isDescendant(of: views[0]) else {
            Logging.shared.log(msg: "can't add constraints view isn't a descendant of view", comp: "[AddressBarView]", type: .err)
            return
        }
        
        // Not active to start
        self.heightConstraint = self.heightAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: views[0].topAnchor),
            self.widthAnchor.constraint(equalTo: views[0].widthAnchor),
            self.bottomAnchor.constraint(equalTo: views[1].topAnchor),
        ])
    }
    
    func animateOut(now: Bool = false) {
        guard self.showingState == .showingCompleted else {
            return
        }
        
        self.showingState = .hidingStarted

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.25
            context.allowsImplicitAnimation = true
            if self.heightConstraint == nil {
                self.heightConstraint = self.heightAnchor.constraint(equalToConstant: 0)
            }
            self.heightConstraint.isActive = true
            self.animator().updateConstraints()
            self.layoutSubtreeIfNeeded()
            
        }, completionHandler: {
            self.showingState = .hidingCompleted
        })
    }
    
    func animateIn(now: Bool = false) {
        guard self.showingState == .hidingCompleted else {
            return
        }
        
        self.showingState = .showingStarted

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.25
            context.allowsImplicitAnimation = true
            heightConstraint.isActive = false
            self.animator().updateConstraints()
            self.layoutSubtreeIfNeeded()
            
        }, completionHandler: {
            self.showingState = .showingCompleted
        })
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AddressBarView: NSTextFieldDelegate {
    
    func controlTextDidEndEditing(_ obj: Notification) {
        let text = addressField.stringValue
        var currentUrl: URL?
        
        if text.count == 0 {
            return
        }
        
        if let url = URL(string: text),
            !Util.isValidWebUrl(url) {
            currentUrl = Util.attemptToFixUrl(urlString: text)
        }
        else {
            currentUrl = URL(string: text)
        }
        
        guard let url = currentUrl,
            Util.isValidWebUrl(currentUrl) else {
            
            Util.showAlert(msg: "Invalid Url")
            Logging.shared.log(msg: "Can't build url", comp: "[AddressBarView]", type: .err)
            return
        }
        
        addressField.resignFirstResponder()
        
        guard let windowId = self.window?.identifier?.rawValue else {
            Logging.shared.log(msg: "Unable send notification without window Id", comp: "[AddressBarView]", type: .err)
            return
        }
        
        NotificationCenter.default.post(name: Notification.WebViewUrlChange(windowId: windowId),
            object: self,
            userInfo: [
                "url": url
            ]
        )
    }
}
