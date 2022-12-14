//
//  WindowUtil.swift
//  zapp
//
//  Created by Joe Manto on 9/6/21.
//

import Foundation
import Cocoa

class WindowUtil {
    
    // MARK: Window Creation
    
    static func createWebWindow() -> SuperWindow {
        let win = SuperWindow()
        win.identifier = NSUserInterfaceItemIdentifier(rawValue: "WEB_WINDOW_\(WindowManager.shared.uniqueId)")
        
        if let delegate = NSApplication.shared.delegate as? AppDelegate {
            win.delegate = delegate
        }
        else {
            assert(false, "[Menu] unable to create new web window - delegate not found")
        }
        let viewController = WebViewController()
        win.contentViewController = viewController
        
        self.setDefaultWindowSize(win)
        
        if let defaultUrl = URL(string: "https://www.google.com") {
            viewController.webView.load(URLRequest(url: defaultUrl))
        }
        
        return win
    }
    
    static func createlocalWindow() -> SuperWindow {
        let win = SuperWindow()
        win.identifier = NSUserInterfaceItemIdentifier(rawValue: "LOCAL_WINDOW_\(WindowManager.shared.uniqueId)")
        
        if let delegate = NSApplication.shared.delegate as? AppDelegate {
            win.delegate = delegate
        }
        else {
            assert(false, "[Menu] unable to create new local file window - delegate not found")
        }
        
        let viewController = LocalViewController()
        viewController.shouldShowAddressBar = false
        win.contentViewController = viewController
        
        self.setDefaultWindowSize(win)
        return win
    }
    
    static func createFromCopiedUrlWindow() -> SuperWindow {
        let win = SuperWindow()
        win.identifier = NSUserInterfaceItemIdentifier(rawValue: "WEB_WINDOW_\(WindowManager.shared.uniqueId)")
        
        if let delegate = NSApplication.shared.delegate as? AppDelegate {
            win.delegate = delegate
        }
        else {
            assert(false, "[Menu] unable to create new local file window - delegate not found")
        }
        
        let viewController = WebViewController()
        win.contentViewController = viewController
        
        if let pasteBoardUrl = Util.getUrlFromPasteBoard() {
            let request = URLRequest(url: pasteBoardUrl)
            viewController.webView.load(request)
        }
        
        self.setDefaultWindowSize(win)
        return win
    }
    
    static func createInfoWindow() -> SuperWindow {
        let win = SuperWindow()
        win.identifier = NSUserInterfaceItemIdentifier(rawValue: "INFO_WINDOW_\(WindowManager.shared.uniqueId)")
        
        if let delegate = NSApplication.shared.delegate as? AppDelegate {
            win.delegate = delegate
        }
        else {
            assert(false, "[Menu] unable to create new info window - delegate not found")
        }
        
        let viewController = WebViewController()
        win.contentViewController = viewController
        
        guard let url = Bundle.main.url(forResource: "welcome", withExtension: "html") else {
            return win
        }
        
        guard let html = try? String(contentsOf: url) else {
            return win
        }
        viewController.webView.loadHTMLString(html, baseURL: url)
        
        guard let screenFrame = NSScreen.main?.frame else {
            win.setContentSize(CGSize(width: 500, height: 800))
            return win
        }
        
        let size = CGSize(width: 500, height: 800)
        let xPos = (screenFrame.width/2) - size.width/2
        let yPos = (screenFrame.height/2) - size.height/2
        win.setFrame(NSRect(x: xPos, y: yPos, width: size.width, height: size.height), display: true)
        return win
    }
    
    static func createReportABugWindow() -> SuperWindow {
        let win = SuperWindow()
        win.identifier = NSUserInterfaceItemIdentifier(rawValue: "REPORT_WINDOW_\(WindowManager.shared.uniqueId)")
        
        if let delegate = NSApplication.shared.delegate as? AppDelegate {
            win.delegate = delegate
        }
        else {
            assert(false, "[Menu] unable to create new info window - delegate not found")
        }
        
        let viewController = WebViewController()
        win.contentViewController = viewController
        
        guard let url = Bundle.main.url(forResource: "bug", withExtension: "html") else {
            return win
        }
        
        guard let html = try? String(contentsOf: url) else {
            return win
        }
        viewController.webView.loadHTMLString(html, baseURL: url)
        
        guard let screenFrame = NSScreen.main?.frame else {
            win.setContentSize(CGSize(width: 500, height: 800))
            return win
        }
        
        let size = CGSize(width: 500, height: 800)
        let xPos = (screenFrame.width/2) - size.width/2
        let yPos = (screenFrame.height/2) - size.height/2
        win.setFrame(NSRect(x: xPos, y: yPos, width: size.width, height: size.height), display: true)
        return win
    }
    
    static func createRequestAFeatureWindow() -> SuperWindow {
        let win = SuperWindow()
        win.identifier = NSUserInterfaceItemIdentifier(rawValue: "FEATURE_WINDOW_\(WindowManager.shared.uniqueId)")
        
        if let delegate = NSApplication.shared.delegate as? AppDelegate {
            win.delegate = delegate
        }
        else {
            assert(false, "[Menu] unable to create new info window - delegate not found")
        }
        
        let viewController = WebViewController()
        win.contentViewController = viewController
        
        guard let url = Bundle.main.url(forResource: "feature", withExtension: "html") else {
            return win
        }
        
        guard let html = try? String(contentsOf: url) else {
            return win
        }
        viewController.webView.loadHTMLString(html, baseURL: url)
        
        guard let screenFrame = NSScreen.main?.frame else {
            win.setContentSize(CGSize(width: 500, height: 800))
            return win
        }
        
        let size = CGSize(width: 500, height: 800)
        let xPos = (screenFrame.width/2) - size.width/2
        let yPos = (screenFrame.height/2) - size.height/2
        win.setFrame(NSRect(x: xPos, y: yPos, width: size.width, height: size.height), display: true)
        return win
    }
    
    static func createPurchasesWindow() -> SuperWindow {
        let win = SuperWindow()
        win.identifier = NSUserInterfaceItemIdentifier(rawValue: "PURCHASES_WINDOW_\(WindowManager.shared.uniqueId)")
        
        if let delegate = NSApplication.shared.delegate as? AppDelegate {
            win.delegate = delegate
        }
        else {
            assert(false, "[Menu] unable to create new info window - delegate not found")
        }
        
        let storyboard = NSStoryboard(name: "Main", bundle: Bundle.main)
        guard let vc = storyboard.instantiateController(withIdentifier: "PurchasesViewController") as? PurchasesViewController else {
            return win
        }
        
        win.contentViewController = vc
            
        let size = CGSize(width: 600, height: 400)
        guard let screenFrame = NSScreen.main?.frame else {
            win.setContentSize(size)
            return win
        }
        
        let xPos = (screenFrame.width/2) - size.width/2
        let yPos = (screenFrame.height/2) - size.height/2
        win.setFrame(NSRect(x: xPos, y: yPos, width: size.width, height: size.height), display: true)
        return win
    }
    
    // MARK: Window Manipulation
    
    static func moveWindow(_ window: NSWindow, location: WindowLocation) {
        Logging.shared.log(msg: "Moving Window \(window.identifier?.rawValue ?? "nil") to \(location)", comp: "[WindowUtil]")
        switch location {
        case .TopRight:
            self.moveWindowTopRight(window)
            break
        case .TopLeft:
            self.moveWindowTopLeft(window)
            break
        case .BottomLeft:
            self.moveWindowBottomLeft(window)
            break
        case .BottomRight:
            self.moveWindowBottomRight(window)
            break
        default:
            return
        }
    }
    
    private static func moveWindowTopRight(_ window: NSWindow) {
        guard let screen = NSScreen.main?.frame else {
            Logging.shared.log(msg: "\(#function) unable to get main screen", comp: "[WindowUtil]", type: .warn)
            return
        }
        
        let windowFrame = window.frame
        
        let xPosition = screen.width - windowFrame.width
        let yPosition = screen.height - windowFrame.height
        window.setFrameOrigin(CGPoint(x: xPosition, y: yPosition))
    }
    
    private static func moveWindowTopLeft(_ window: NSWindow) {
        guard let screen = NSScreen.main?.frame else {
            Logging.shared.log(msg: "\(#function) unable to get main screen", comp: "[WindowUtil]", type: .warn)
            return
        }
        
        let windowFrame = window.frame
        
        let yPosition = screen.height - windowFrame.height
        window.setFrameOrigin(CGPoint(x: 0, y: yPosition))
    }
    
    private static func moveWindowBottomLeft(_ window: NSWindow) {
        window.setFrameOrigin(CGPoint(x: 0, y: 0))
    }
    
    private static func moveWindowBottomRight(_ window: NSWindow) {
        guard let screen = NSScreen.main?.frame else {
            Logging.shared.log(msg: "\(#function) unable to get main screen", comp: "[WindowUtil]", type: .warn)
            return
        }
        
        let windowFrame = window.frame
        
        let xPosition = screen.width - windowFrame.width
        window.setFrameOrigin(CGPoint(x: xPosition, y: 0))
    }
    
    private static func setDefaultWindowSize(_ window: NSWindow) {
        var width = Settings.shared.integer(forKey: Setting.lastWindowWidth, log: true)
        var height = Settings.shared.integer(forKey: Setting.lastWindowHeight, log: true)
        let useDefaultWindowSize = Settings.shared.integer(forKey: Setting.useLastWindowSize, log: true) == 0
        
        if width < Int(MIN_WINDOW_SIZE.width)
            || height < Int(MIN_WINDOW_SIZE.height)
            || useDefaultWindowSize {
            
            width = Int(DEFAULT_WINDOW_FRAME.width)
            height = Int(DEFAULT_WINDOW_FRAME.height)
        }
        
        if let screenFrame = NSScreen.main?.frame {
            let size = CGSize(width: width, height: height)
            let centerX = (screenFrame.width/2) - size.width/2
            let centerY = (screenFrame.height/2) - size.height/2
            window.setFrame(NSRect(x: centerX, y: centerY, width: size.width, height: size.height), display: true)
            return
        }
        let posX = DEFAULT_WINDOW_FRAME.origin.x
        let posY = DEFAULT_WINDOW_FRAME.origin.y
        let rect = NSRect(x: posX, y: posY, width: CGFloat(width), height: CGFloat(height))
    
        window.setFrame(rect, display: true)
    }
}
