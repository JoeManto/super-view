//
//  AppDelegate.swift
//  zapp
//
//  Created by Joe Manto on 9/4/21.
//

import Cocoa
import StoreKit

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var statusItem: NSStatusItem = {
        NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    }()
    
    var menu: Menu = {
        Menu()
    }()
    
    var trialController: FreeTrialController = {
       FreeTrialController()
    }()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        //self.setUpStoreKit()
        //trialController.updateTrial()
        Settings.shared.set(1, forKey: Product.FullAccess.rawValue)
        
        Settings.shared.readyForLogging = true
        Logging.shared.log(marker: "App Started")
        
        self.setupStatusItem()
        self.showWelcomeViewIfNeeded()
        
        /*Util.checkIfAppIsOutdatedIfNeeded(comp: { isOutDated in
            if isOutDated {
                self.menu.refreshMenu()
            }
        })*/
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        Logging.shared.log(marker: "App Will Terminate")
        SKPaymentQueue.default().remove(IAPManager.shared)
    }
}

extension AppDelegate {
    
    func showWelcomeViewIfNeeded() {
        if Util.increaseNumberOfAppRuns() == 1 {
            WindowManager.shared.create(.Info)
        }
    }
    
    func setupMainWindow() {
        let win = WindowManager.shared.create(.Info)
        WindowManager.shared.show(win)
    }
    
    func setupStatusItem() {
        let btn = self.statusItem.button
        btn?.action = #selector(statusItemClicked(_:))
        btn?.sendAction(on: [.leftMouseDown, .rightMouseDown])
        
        if let image = NSImage(named: "status-icon") {
            btn?.image = image
        }
    }
    
    @objc func statusItemClicked(_ sender: NSStatusBarButton) {
        Logging.shared.log(marker: "Menu Opened")
        self.trialController.updateTrial()
        menu.refreshMenu()
        menu.showMenu(near: NSEvent.mouseLocation)
    }
    
    func setUpStoreKit() {
        if let url = Bundle.main.appStoreReceiptURL, let _ = try? Data(contentsOf: url) {
            SKPaymentQueue.default().add(IAPManager.shared)
            IAPManager.shared.fetchProducts()
        }
        else {
            // Validation fails. The receipt does not exist.
            exit(173)
        }
    }
}

extension AppDelegate: NSWindowDelegate {
    func windowWillResize(_ sender: NSWindow, to frameSize: NSSize) -> NSSize {
        
        if frameSize.width <= MIN_WINDOW_SIZE.width,
           frameSize.height <= MIN_WINDOW_SIZE.height {
            return frameSize
        }
        Settings.shared.setValue(frameSize.width, forKey: Setting.lastWindowWidth, log: false)
        Settings.shared.setValue(frameSize.height, forKey: Setting.lastWindowHeight, log: false)
        
        return frameSize
    }
    
    func windowWillClose(_ notification: Notification) {
        guard let win = notification.object as? NSWindow else {
            return
        }
        
        Logging.shared.log(msg: "Window closed with id: \(win.identifier?.rawValue ?? "nil")")
        
        win.delegate = nil
        WindowManager.shared.remove(win)
    }
    
    func windowDidChangeOcclusionState(_ notification: Notification) {
        guard let win = notification.object as? SuperWindow else {
            return
        }
        
        let occlusionState = win.occlusionState
        guard occlusionState.rawValue == 8192,
              !win.isMiniaturized else {
            return
        }
        
        Logging.shared.log(msg: "OcclusionState changed window \(win.identifier?.rawValue ?? "nil") is not visible, making key and ordering", comp: "[OcclusionState]")

        guard let id = win.identifier?.rawValue else {
            Logging.shared.log(msg: "Unable to get window Id", comp: "[OcclusionState]", type: .err)
            return
        }
        
        guard let controller = WindowManager.shared.activeWindows[id] else {
            Logging.shared.log(msg: "Unable to get window controller for id \(id)", comp: "[OcclusionState]", type: .err)
            return
        }
       
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            win.makeKeyAndOrderFront(controller)
        }
    }
}

