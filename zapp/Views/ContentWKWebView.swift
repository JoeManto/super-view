//
//  ContentWKWebView.swift
//  zapp
//
//  Created by Joe Manto on 9/4/21.
//

import Foundation
import WebKit

class ContentWKWebView: WKWebView {
    
    var topConstraint: NSLayoutConstraint!
    
    required init() {
        let config = WKWebViewConfiguration()
        config.limitsNavigationsToAppBoundDomains = false
        config.suppressesIncrementalRendering = true
        config.preferences.setValue(true, forKey: "fullScreenEnabled")
        config.preferences._setFullScreenEnabled(true)
        config.preferences.javaScriptCanOpenWindowsAutomatically = false
    
        super.init(frame: .zero, configuration: config)
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.white.cgColor
    }
    
    override func viewDidMoveToWindow() {
        guard let window = self.window else {
            return
        }
        
        window.minFullScreenContentSize = NSSize(width: 0, height: 0)
        window.maxFullScreenContentSize = NSSize(width: 0, height: 0)
        super.viewDidMoveToWindow()
    }

    func setUpContraints(on views: [NSView]) {
        guard views.count >= 2,
              self.isDescendant(of: views[0]) else {
            Logging.shared.log(msg: "can't add constraints view isn't a descendant of view", comp: "[ContentWKWebView]", type: .err)
            return
        }
        
        self.topConstraint = self.topAnchor.constraint(equalTo: views[1].bottomAnchor)
        
        NSLayoutConstraint.activate([
            topConstraint,
            self.widthAnchor.constraint(equalTo: views[0].widthAnchor),
            self.bottomAnchor.constraint(equalTo: views[0].bottomAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
