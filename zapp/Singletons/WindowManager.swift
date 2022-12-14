//
//  WindowManager.swift
//  zapp
//
//  Created by Joe Manto on 9/6/21.
//

import Foundation
import Cocoa

class WindowManager {
    static let shared = WindowManager()
    
    private(set) var activeWindows: [String : NSWindowController] = [:]
    /// The number of windows added in total
    /// This number only increases and doesn't decrease as windows are removed
    /// Ensures every new window will have a unquie window Id
    private(set) var uniqueId: UInt = 0
    
    private init() {}
    
    @discardableResult func create(_ type: WindowType, shouldShow: Bool = true) -> SuperWindow {
        var window: SuperWindow!
        
        defer {
            self.add(window)
            Logging.shared.log(msg: "Window Created With Id: \(window.identifier?.rawValue ?? "nil")")
            
            if (shouldShow) {
                self.show(window)
            }
        }
        
        switch type {
            case .Web:
                window = WindowUtil.createWebWindow()
                break
            case .Local:
                window = WindowUtil.createlocalWindow()
                break
            case .Info:
                window = WindowUtil.createInfoWindow()
                break
            case .Bug:
                window = WindowUtil.createReportABugWindow()
                break
            case .Feature:
                window = WindowUtil.createRequestAFeatureWindow()
                break
            case .FromCopy:
                window = WindowUtil.createFromCopiedUrlWindow()
                break
            case .Purchases:
                window = WindowUtil.createPurchasesWindow()
                break
        }
        
        return window
    }
    
    func add(_ window: NSWindow) {
        guard let id = window.identifier?.rawValue else {
            Logging.shared.log(msg: "Window must have an id \(#function)", comp: "[WindowManager]", type: .err)
            return
        }
        
        let windowController = NSWindowController(window: window)
        self.activeWindows[id] = windowController
        self.uniqueId += 1
    }
    
    func remove(with id: String) {
        self.activeWindows[id]?.window?.close()
        self.activeWindows[id]?.close()
        self.activeWindows.removeValue(forKey: id)
    }
    
    func remove(_ window: NSWindow) {
        guard let id = window.identifier?.rawValue else {
            Logging.shared.log(msg: "Window must have an id \(#function)", comp: "[WindowManager]", type: .err)
            return
        }
        self.remove(with: id)
    }
    
    func removeKeyWindow() {
        Logging.shared.log(msg: "Removing Key Window")
        guard let keyWindow = self.getKeyWindow() else {
            return
        }
        self.remove(keyWindow)
    }
    
    func removeAllWindows(of type: WindowType) {
        for id in Array(self.activeWindows.keys) {
            if let window = self.activeWindows[id]?.window as? SuperWindow,
               window.type == type {
                self.remove(with: id)
            }
        }
    }
    
    func show(_ id: String) {
        guard let window = self.activeWindows[id]?.window else {
            Logging.shared.log(msg: "must have controller for id \(id) or window controller must have window \(#function)", comp: "[WindowManager]", type: .err)
            return
        }
        window.makeKeyAndOrderFront(self.activeWindows[id])
    }
    
    func show(_ window: NSWindow) {
        guard let id = window.identifier?.rawValue else {
            Logging.shared.log(msg: "Window must have an id \(#function)", comp: "[WindowManager]", type: .err)
            return
        }
        window.makeKeyAndOrderFront(self.activeWindows[id])
    }
    
    func getKeyWindow() -> NSWindow? {
        for key in Array(self.activeWindows.keys) {
            guard let window = self.activeWindows[key]?.window else {
                continue
            }
            
            if window.isKeyWindow {
                return window
            }
        }
        
        Logging.shared.log(msg: "No Key Window Found \(#function)", comp: "[WindowManager]", type: .warn)
        return nil
    }
}
