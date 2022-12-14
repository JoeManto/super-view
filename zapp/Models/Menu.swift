//
//  Menu.swift
//  zapp
//
//  Created by Joe Manto on 9/6/21.
//

import Foundation
import Cocoa

class Menu: NSMenu {
    
    init() {
        super.init(title: MenuTitles.title)
        self.buildMenu()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildMenu() {
        self.buildFromCopiedUrlIfNeeded()
        self.addItem(self.item(title: MenuTitles.webWindow, action: #selector(self.newWebWindow(_:)), keyEquivalent: "", image: nil))
        self.addItem(self.item(title: MenuTitles.localWindow, action: #selector(self.openLocalFile(_:)), keyEquivalent: "", image: nil))
        self.addItem(NSMenuItem.separator())
        
        self.buildMoveItems()
        self.buildAddressBarItems()
        self.buildSettingsItems()
        self.addItem(NSMenuItem.separator())
        
        /*if Settings.shared.integer(forKey: Setting.isOutDated, log: true) == 1 {
            self.buildOutOfDateItem()
        }*/
        
        self.buildPurchaseItem()
        
        onDebug {
            self.buildDebugItem()
        }
        
        if let reminder = self.buildTrialReminderIfNeeded() {
            self.addItem(reminder)
        }
        self.buildSupportItems()
        self.addItem(NSMenuItem(title: MenuTitles.quit, action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
    }
    
    // MARK: Building Sub Menus
    
    private func buildFromCopiedUrlIfNeeded() {
        let fromCopyItem = self.item(title: MenuTitles.fromCopy, action: #selector(self.openFromCopiedUrl(_:)), keyEquivalent: "", image: nil)
        self.addItem(fromCopyItem)
        
        guard let _ = Util.getUrlFromPasteBoard() else {
            fromCopyItem.isHidden = true
            return
        }
    }
    
    private func buildMoveItems() {
        let moveTitle = item(title: MenuTitles.move, action: nil, keyEquivalent: "", image: nil)
        self.addItem(moveTitle)
        
        if (WindowManager.shared.activeWindows.count <= 0) {
            moveTitle.isEnabled = false
        }
        
        let moveSubMenu = NSMenu(title: MenuTitles.move)
        moveSubMenu.addItem(withTitle: MenuTitles.moveCurrentWindow, action: nil, keyEquivalent: "")
        moveSubMenu.addItem(NSMenuItem.separator())
        
        let topLeftItem = self.item(title: MenuTitles.moveTopLeft,
                                     action: #selector(self.moveTopLeft(_:)),
                                     keyEquivalent: "",
                                     image: NSImage(named: "move-top-left"))
        moveSubMenu.addItem(topLeftItem)
        
        let topRightItem = self.item(title: MenuTitles.moveTopRight,
                                     action: #selector(self.moveTopRight(_:)),
                                     keyEquivalent: "",
                                     image: NSImage(named: "move-top-right"))
        moveSubMenu.addItem(topRightItem)
        
        let bottomLeftItem = self.item(title: MenuTitles.moveBottomLeft,
                                       action: #selector(self.moveBottomLeft(_:)),
                                       keyEquivalent: "",
                                       image: NSImage(named: "move-bottom-left"))
        moveSubMenu.addItem(bottomLeftItem)
        
        let bottomRightItem = self.item(title: MenuTitles.moveBottomRight,
                                        action: #selector(self.moveBottomRight(_:)),
                                        keyEquivalent: "",
                                        image: NSImage(named: "move-bottom-right"))
        moveSubMenu.addItem(bottomRightItem)
        self.setSubmenu(moveSubMenu, for: moveTitle)
    }
    
    private func buildSupportItems() {
        let supportTitle = item(title: MenuTitles.support, action: nil, keyEquivalent: "", image: nil)
        self.addItem(supportTitle)
        let supportSubMenu = NSMenu(title: MenuTitles.support)
        supportSubMenu.addItem(withTitle: MenuTitles.support, action: nil, keyEquivalent: "")
        supportSubMenu.addItem(NSMenuItem.separator())
        
        let welcomeItem = self.item(title: MenuTitles.infoWindow,
                                    action: #selector(self.openWelcomeWindow(_:)),
                                    keyEquivalent: "", image: nil)
        supportSubMenu.addItem(welcomeItem)
        
        let featureItem = self.item(title: MenuTitles.requestAFeature,
                                    action: #selector(self.requestFeature(_:)),
                                    keyEquivalent: "", image: nil)
        supportSubMenu.addItem(featureItem)
        
        let bugItem = self.item(title: MenuTitles.reportABug,
                                action: #selector(self.reportBug(_:)),
                                keyEquivalent: "", image: nil)
        supportSubMenu.addItem(bugItem)
        
        let saveLogs = self.item(title: MenuTitles.saveLogs,
                                 action: #selector(self.saveLogs(_:)),
                                 keyEquivalent: "", image: nil)
        supportSubMenu.addItem(saveLogs)
        
        let resetLogs = self.item(title: MenuTitles.resetLogs,
                                 action: #selector(self.resetLogs(_:)),
                                 keyEquivalent: "", image: nil)
        supportSubMenu.addItem(resetLogs)
        
        self.setSubmenu(supportSubMenu, for: supportTitle)
    }
    
    private func buildDebugItem() {
        let debugTitle = item(title: "Debug", action: nil, keyEquivalent: "", image: nil)
        self.addItem(debugTitle)
        let debugSubMenu = NSMenu(title: "Debug")
        debugSubMenu.addItem(withTitle: "Debug", action: nil, keyEquivalent: "")
        debugSubMenu.addItem(NSMenuItem.separator())
        
        let resetDefaults = self.item(title: "Reset Defaults",
                                 action: #selector(self.resetDefaults(_:)),
                                 keyEquivalent: "", image: nil)
        debugSubMenu.addItem(resetDefaults)
        
        let resetICloudDefaults = self.item(title: "Reset iCloud Defaults",
                                 action: #selector(self.resetICloudDefaults(_:)),
                                 keyEquivalent: "", image: nil)
        debugSubMenu.addItem(resetICloudDefaults)
        
        self.setSubmenu(debugSubMenu, for: debugTitle)
    }
    
    private func buildAddressBarItems() {
        let addressBarTitle = item(title: MenuTitles.addressBar, action: nil, keyEquivalent: "", image: nil)
        self.addItem(addressBarTitle)
        let addressBarSubMenu = NSMenu(title: MenuTitles.addressBar)
        addressBarSubMenu.addItem(withTitle: MenuTitles.controlCurrentAddressBar, action: nil, keyEquivalent: "")
        addressBarSubMenu.addItem(NSMenuItem.separator())
        
        let hideAddressBar = self.item(title: MenuTitles.hideAddressBar,
                                    action: #selector(self.hideAddressBar(_:)),
                                    keyEquivalent: "", image: nil)
        addressBarSubMenu.addItem(hideAddressBar)
        
        let showAddressBar = self.item(title: MenuTitles.showAddressBar,
                                    action: #selector(self.showAddressBar(_:)),
                                    keyEquivalent: "", image: nil)
        addressBarSubMenu.addItem(showAddressBar)

        self.setSubmenu(addressBarSubMenu, for: addressBarTitle)
    }
    
    private func buildSettingsItems() {
        let settingsTitle = item(title: MenuTitles.settings, action: nil, keyEquivalent: "", image: nil)
        self.addItem(settingsTitle)
        
        let settingsSubMenu = NSMenu(title: MenuTitles.settings)
   
        let autoHideAddressBarItem = self.settingItem(title: MenuTitles.autoHideAddressBar,
                                                      action: #selector(self.autoHideAddressBarToggle(_:)),
                                                      settingKey: Setting.autoHideAddressBar)
        settingsSubMenu.addItem(autoHideAddressBarItem)
        
        let useLastWindowSizeItem = self.settingItem(title: MenuTitles.useLastWindowSize,
                                                      action: #selector(self.useLastWindowSize(_:)),
                                                      settingKey: Setting.useLastWindowSize)
        settingsSubMenu.addItem(useLastWindowSizeItem)
        
        settingsSubMenu.addItem(NSMenuItem.separator())
        let resetItem = self.item(title: MenuTitles.reset, action: #selector(self.resetSettings(_:)), keyEquivalent: "", image: nil)
        settingsSubMenu.addItem(resetItem)
        
        self.setSubmenu(settingsSubMenu, for: settingsTitle)
    }
    
    private func buildOutOfDateItem() {
        let outOfDateItem = item(title: MenuTitles.outOfDate, action: #selector(self.appIsOutOfDate(_:)), keyEquivalent: "", image: nil)
        outOfDateItem.isHidden = Settings.shared.integer(forKey: Setting.isOutDated, log: true) == 0
        self.addItem(outOfDateItem)
    }
    
    private func buildPurchaseItem() {
        let purchaseItem = self.item(title: MenuTitles.showPurchases, action: #selector(self.showPurchases(_:)), keyEquivalent: "", image: nil)
        self.addItem(purchaseItem)
    }
    
    private func buildTrialReminderIfNeeded() -> NSMenuItem? {
        guard Settings.shared.hasFullAccess() == false else {
            return nil
        }
        
        var title = ""
        let endDateRaw = Settings.shared.double(forKey: Setting.freeTrialEndDate)
        
        if endDateRaw < Date().timeIntervalSince1970 {
            title = "Free trial ended"
        }
        else {
            let date = Date(timeIntervalSince1970: endDateRaw)
            let daysLeft = abs(Calendar.current.numberOfDaysBetween(date, and: Date()))
            
            if daysLeft > 0 {
                title = "Trial ending in \(daysLeft) days"
            }
            else {
                title = "Trial ending soon"
            }
        }
        
        let trialReminder = self.item(title: title, action: nil, keyEquivalent: "", image: nil)
        trialReminder.tag = 10
        return trialReminder
    }
    
    // MARK: Menu Updates / Refreshs
    
    func refreshMenu() {
        if let outOfDateItem = self.item(withTitle: MenuTitles.outOfDate) {
            outOfDateItem.isHidden = Settings.shared.integer(forKey: Setting.isOutDated, log: true) == 0
        }
        
        self.updateMoveItems()
        self.updateTrialReminder()
        self.updateFromCopyItem()
        self.updateSettingsItems()
        self.updateAddressBarItems()
    }
    
    private func updateSettingsItems() {
        guard let settingsItem = self.item(withTitle: MenuTitles.settings),
              let submenu = settingsItem.submenu else {
              return
        }
        
        let settings = [Setting.autoHideAddressBar, Setting.useLastWindowSize]
        for (i, item) in submenu.items.enumerated() {
            guard i < settings.count else {
                return
            }
            let settingValue = Settings.shared.integer(forKey: settings[i], log: true)
            item.image = NSImage(named: "setting-\(settingValue > 0 ? "enabled" : "disabled")")
        }
    }
    
    private func updateAddressBarItems() {
        guard let keyWindow = WindowManager.shared.getKeyWindow(),
              let _ = keyWindow.contentViewController as? WebViewController else {
            self.item(withTitle: MenuTitles.addressBar)?.isEnabled = false
            return
        }
        
        self.item(withTitle: MenuTitles.addressBar)?.isEnabled = true
    }
    
    private func updateMoveItems() {
        guard WindowManager.shared.getKeyWindow() != nil else {
            self.item(withTitle: MenuTitles.move)?.isEnabled = false
            return
        }
        self.item(withTitle: MenuTitles.move)?.isEnabled = true
    }
    
    private func updateFromCopyItem() {
        let fromCopy = self.item(withTitle: MenuTitles.fromCopy)
        guard let _ = Util.getUrlFromPasteBoard() else {
            fromCopy?.isHidden = true
            return
        }
        
        fromCopy?.isHidden = false
    }
    
    private func updateTrialReminder() {
        guard Settings.shared.hasFullAccess() == false else {
            if let reminder = self.item(withTag: 10) {
                self.removeItem(reminder)
            }
            return
        }
       
        guard let reminder = self.item(withTag: 10),
              let updatedItem = self.buildTrialReminderIfNeeded() else {
            return
        }
        reminder.title = updatedItem.title
        
        self.itemChanged(reminder)
    }
    
    // MARK: Helpers
    
    private func item(title: String, action: Selector?, keyEquivalent: String, image: NSImage?) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: keyEquivalent)
        item.target = self
        item.image = image
        return item
    }
    
    private func settingItem(title: String, action: Selector?, settingKey: String) -> NSMenuItem {
        let isSettingEnabled = Settings.shared.integer(forKey: settingKey, log: true) > 0
        let image = NSImage(named: "setting-\(isSettingEnabled ? "enabled" : "disabled")")
        let item = self.item(title: title, action: action, keyEquivalent: "", image: image)
        item.tag = isSettingEnabled ? 1 : 0
        return item
    }
    
    func showMenu(near location: CGPoint) {
        var newLocation = location
        newLocation.y = NSScreen.main!.frame.height - NSStatusBar.system.thickness - 10
        
        let contentRect = NSRect(origin: newLocation, size: CGSize(width: 0, height: 0))
        
        let tmpWindow = NSWindow(contentRect: contentRect, styleMask: .borderless, backing: .buffered, defer: false)
        tmpWindow.isReleasedWhenClosed = true
        tmpWindow.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.maximumWindow)))
        
        self.popUp(positioning: nil, at: .zero, in: tmpWindow.contentView)
    }
    
    func toggleSetting(settingKey: String) {
        Settings.shared.toggle(forKey: settingKey)
        self.refreshMenu()
    }
    
    // MARK: Selectors
    
    @objc func moveTopRight(_ sender: NSButton) {
        if let key = WindowManager.shared.getKeyWindow() {
            WindowUtil.moveWindow(key, location: .TopRight)
        }
    }
    
    @objc func moveTopLeft(_ sender: NSButton) {
        if let key = WindowManager.shared.getKeyWindow() {
            WindowUtil.moveWindow(key, location: .TopLeft)
        }
    }
    
    @objc func moveBottomLeft(_ sender: NSButton) {
        if let key = WindowManager.shared.getKeyWindow() {
            WindowUtil.moveWindow(key, location: .BottomLeft)
        }
    }
    
    @objc func moveBottomRight(_ sender: NSButton) {
        if let key = WindowManager.shared.getKeyWindow() {
            WindowUtil.moveWindow(key, location: .BottomRight)
        }
    }

    @objc func newWebWindow(_ sender: NSButton) {
        guard Settings.shared.hasFullAccess() || Settings.shared.hasTrialAccess() else {
            let alert = NSAlert()
            alert.messageText = AlertTitles.trialEnded
            alert.informativeText = AlertMessages.trialEnded
            alert.addButton(withTitle: "Show Purchases")
            alert.alertStyle = .warning
            let result = alert.runModal()
            
            if result == .alertFirstButtonReturn {
                self.showPurchases(alert.buttons[0])
            }
        
            return
        }
        WindowManager.shared.create(.Web)
    }
    
    @objc func openLocalFile(_ sender: NSButton) {
        guard Settings.shared.hasFullAccess() || Settings.shared.hasTrialAccess() else {
            let alert = NSAlert()
            alert.messageText = AlertTitles.trialEnded
            alert.informativeText = AlertMessages.trialEnded
            alert.addButton(withTitle: "Show Purchases")
            alert.buttons[0].target = self
            alert.buttons[0].action = #selector(showPurchases(_:))
            alert.buttons[0].tag = 1
            alert.alertStyle = .warning
            return
        }
        WindowManager.shared.create(.Local)
    }
    
    @objc func openWelcomeWindow(_ sender: NSButton) {
        WindowManager.shared.create(.Info)
    }
    
    @objc func openFromCopiedUrl(_ sender: NSButton) {
        WindowManager.shared.create(.FromCopy)
    }
    
    @objc func reportBug(_ sender: NSButton) {
        WindowManager.shared.create(.Bug)
    }
    
    @objc func requestFeature(_ sender: NSButton) {
        WindowManager.shared.create(.Feature)
    }
    
    @objc func saveLogs(_ sender: NSButton) {
        Logging.shared.saveLogs()
    }
    
    @objc func resetLogs(_ sender: NSButton) {
        Logging.shared.resetLogs()
    }
    
    @objc func appIsOutOfDate(_ sender: NSButton) {
        if let url = URL(string: "macappstore://apps.apple.com/us/app/mirror-magnet/id1563698880?mt=12") {
            NSWorkspace.shared.open(url)
        }
    }
    
    @objc func hideAddressBar(_ sender: NSButton) {
        guard let keyWindow = WindowManager.shared.getKeyWindow(),
              let vc = keyWindow.contentViewController as? WebViewController else {
            assert(false, "[Menu] HideAddressBar unable to get keyWindow or no content view controller")
            return
        }
        vc.hideAddressBar(now: true)
    }
    
    @objc func showAddressBar(_ sender: NSButton) {
        guard let keyWindow = WindowManager.shared.getKeyWindow(),
              let vc = keyWindow.contentViewController as? WebViewController else {
            assert(false, "[Menu] ShowAddressBar unable to get keyWindow or no content view controller")
            return
        }
        vc.showAddressBar(now: true)
    }
    
    @objc func autoHideAddressBarToggle(_ sender: NSButton) {
        self.toggleSetting(settingKey: Setting.autoHideAddressBar)
    }
    
    @objc func useLastWindowSize(_ sender: NSButton) {
        self.toggleSetting(settingKey: Setting.useLastWindowSize)
    }
    
    @objc func resetSettings(_ sender: NSButton) {
        Settings.shared.reset()
    }
    
    @objc func showPurchases(_ sender: NSButton) {
        WindowManager.shared.create(.Purchases)
    }
    
    // MARK: Debug Only
    
    @objc func resetDefaults(_ sender: NSButton) {
        onDebug {
            Settings.shared.resetAllKeys()
        }
    }
    
    @objc func resetICloudDefaults(_ sender: NSButton) {
        onDebug {
            NSUbiquitousKeyValueStore.default.set(0, forKey: ICloudKVP.freeTrialEndDate)
        }
    }
}
