//
//  Settings.swift
//  zapp
//
//  Created by Joe Manto on 9/8/21.
//

import Foundation

class Settings : UserDefaults {
    static var shared = Settings(suiteName: "group.com.superview.joemanto.defaults")!
    
    var readyForLogging = false
    
    override init?(suiteName suitename: String?) {
        super.init(suiteName: suitename)
        self.setDefaultsIfNeeded()
    }
    
    func setValue(_ value: Any?, forKey key: String, log: Bool) {
        super.setValue(value, forKey: key)
        var key = key
        
        if Product(rawValue: key) == .FullAccess {
            key = "Full Access"
        }
        
        if readyForLogging && log {
            Logging.shared.log(msg: "Set: \(key) -> \(value ?? "nil")", comp: "[Settings]")
        }
    }
    
    func string(forKey defaultName: String, log: Bool = true) -> String? {
        let value = super.string(forKey: defaultName)
        var key = defaultName
        
        if Product(rawValue: key) == .FullAccess {
            key = "Full Access"
        }
        
        if readyForLogging && log {
            Logging.shared.log(msg: "\(key) -> \(value ?? "na")", comp: "[Settings]")
        }
        return value
    }
    
    func integer(forKey defaultName: String, log: Bool = true) -> Int {
        let value = super.integer(forKey: defaultName)
        var key = defaultName
        
        if Product(rawValue: key) == .FullAccess {
            key = "Full Access"
        }
        
        if readyForLogging {
            Logging.shared.log(msg: "\(key) -> \(value)", comp: "[Settings]")
        }
        return value
    }
    
    @discardableResult func toggle(forKey defaultName: String, log: Bool = true) -> Int {
        let value = self.integer(forKey: defaultName)
        let new = value > 0 ? 0 : 1
        if readyForLogging && log {
            Logging.shared.log(msg: "Toggle: \(defaultName) from \(value) to \(new)", comp: "[Settings]")
        }
        self.setValue(new, forKey: defaultName)
        return new
    }
    
    private func setDefaultsIfNeeded() {
        guard self.integer(forKey: Setting.defaultValuesApplied) <= 0 else {
            return
        }
        
        self.reset()
        
        self.setValue(1, forKey: Setting.defaultValuesApplied)
        if readyForLogging {
            Logging.shared.log(msg: "Default Settings Applied")
        }
    }
    
    func reset() {
        if readyForLogging {
            Logging.shared.log(msg: "Reset Settings")
        }
        self.setValue(1, forKey: Setting.autoHideAddressBar)
        self.setValue(1, forKey: Setting.useLastWindowSize)
    }
    
    func hasFullAccess() -> Bool {
        return self.integer(forKey: Product.FullAccess.rawValue, log: true) > 0
    }
    
    func hasTrialAccess() -> Bool {
        return self.integer(forKey: Setting.freeTrialAccess, log: true) > 0
    }
    
    static func shouldAutoHide() -> Bool {
        return Settings.shared.integer(forKey: Setting.autoHideAddressBar, log: true) > 0
    }
    
    func resetAllKeys() {
        let dictionary = self.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            self.removeObject(forKey: key)
        }
    }
}
