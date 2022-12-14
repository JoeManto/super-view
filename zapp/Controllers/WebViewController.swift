//
//  ViewController.swift
//  zapp
//
//  Created by Joe Manto on 9/4/21.
//

import Cocoa
import WebKit

class WebViewController: NSViewController {
    
    let webView: ContentWKWebView = {
       ContentWKWebView()
    }()
    
    let addressBar: AddressBarView = {
       AddressBarView()
    }()
    
    var isShowingAddressBar = true
    var shouldShowAddressBar = true
    var lastUserEnteredAddress: String?
    
    override func viewDidAppear() {
        guard let windowId = self.view.window?.identifier?.rawValue else {
            Logging.shared.log(msg: "Unable to setup notification without window Id", type: .err)
            return
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(webViewNavigationRequest(_:)),
            name: Notification.WebViewUrlChange(windowId: windowId),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(webViewNavigationRequest(_:)),
            name: Notification.WebViewDirectionChange(windowId: windowId),
            object: nil
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.webView.navigationDelegate = self
        
        guard self.shouldShowAddressBar else {
            return
        }
        
        self.updateAddressControl()
        
        var options: NSTrackingArea.Options = .activeAlways
        options.formUnion(.inVisibleRect)
        options.formUnion(.mouseMoved)
        options.formUnion(.mouseEnteredAndExited)
        let area = NSTrackingArea(rect: self.view.bounds, options: options, owner: self, userInfo: nil)
        self.view.addTrackingArea(area)
    }
    
    override func loadView() {
        let view = NSView()
        view.translatesAutoresizingMaskIntoConstraints = false
        if shouldShowAddressBar {
            view.addSubview(addressBar)
        }
        view.addSubview(webView)
        self.view = view
        self.setUpContraints()
    }
    
    func setUpContraints() {
        // Set min view size. Window will fit to content view size
        NSLayoutConstraint.activate([
            self.view.widthAnchor.constraint(greaterThanOrEqualToConstant: 150),
            self.view.heightAnchor.constraint(greaterThanOrEqualToConstant: 50)
        ])
        
        if shouldShowAddressBar {
            addressBar.setUpContraints(on: [self.view, webView])
        }
        webView.setUpContraints(on: [self.view, addressBar])
    }
    
    // MARK: Address Bar
    
    private func updateAddressControl() {
        guard self.shouldShowAddressBar else {
            return
        }
        
        var newDirections = [WebViewDirectionOption]()
        
        if self.webView.canGoForward {
            newDirections.append(.forward)
        }
        if self.webView.canGoBack {
            newDirections.append(.backward)
        }
        
        let model = AddressBarControlViewModel(directions: newDirections)
        addressBar.addressControl.updateView(model: model)
    }
    
    func updateAddressBar(with urlString: String) {
        self.addressBar.addressField.stringValue = urlString
        self.updateAddressControl()
    }
    
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        guard Settings.shouldAutoHide() else {
            return
        }
        
        self.addressBar.animateIn()
    }
    
    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        guard Settings.shouldAutoHide() else {
            return
        }
        
        self.addressBar.animateOut()
    }
    
    func hideAddressBar(now: Bool) {
        self.addressBar.animateOut(now: now)
    }
    
    func showAddressBar(now: Bool) {
        self.addressBar.animateIn(now: now)
    }
    
    // MARK: Navigation
    
    func navigateWebview(direction: WebViewDirectionOption) {
        if direction == .forward {
            if webView.canGoForward {
                self.webView.goForward()
            }
        }
        else if direction == .backward {
            if webView.canGoBack {
                self.webView.goBack()
            }
        }
    }
    
    func navigateWebview(for url: URL) {
        // Check if we already loaded this url
        if let currentUrl = webView.url?.absoluteString,
           currentUrl == url.absoluteString {
            return
        }
        
        addressBar.addressField.stringValue = url.absoluteString
        lastUserEnteredAddress = url.absoluteString
        let request = URLRequest(url: url)
        self.webView.load(request)
        self.updateAddressControl()
    }
    
    @objc func webViewNavigationRequest(_ notf: Notification) {
        guard let userInfo = notf.userInfo, userInfo.count > 0 else {
            Logging.shared.log(msg: "No user info for notification \(notf.name)", comp: "[WebViewController]", type: .err)
            return
        }
        
        if let direction = userInfo["direction"] as? WebViewDirectionOption {
            DispatchQueue.main.async {
                self.navigateWebview(direction: direction)
            }
            return
        }
        
        if let url = userInfo["url"] as? URL {
            DispatchQueue.main.async {
                self.navigateWebview(for: url)
            }
        }
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


