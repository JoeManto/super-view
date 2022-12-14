//
//  Constants.swift
//  zapp
//
//  Created by Joe Manto on 9/4/21.
//

import Foundation

let DEFAULT_WINDOW_FRAME = NSRect(x: 50, y: 100, width: 500, height: 500)
let MIN_WINDOW_SIZE = NSSize(width: 150, height: 50)
let TRIAL_LENGTH = 259200

struct Setting {
    static let numAppRuns = "NUM_APP_RUNS"
    static let defaultValuesApplied = "DEFAULT_VALUES_APPLIED"
    static let lastAppUpdateCheck = "LAST_UPDATE_CHECK_DATE"
    static let upToDateVersion = "UP_TO_DATE_VERSION"
    static let freeTrialEndDate = "LOCAL_FREE_TRIAL_END_DATE"
    static let freeTrialAccess = "HAS_TRIAL_ACCESS"
    static let isOutDated = "IS_OUT_DATED"
    static let logFileUrl = "LOG_FILE_URL"
    
    static let lastWindowWidth = "LAST_WINDOW_WIDTH"
    static let lastWindowHeight = "LAST_WINDOW_HEIGHT"
    
    static let autoHideAddressBar = "AUTO_HIDE_ADDRESS_BAR"
    static let useLastWindowSize = "USE_LAST_WINDOW_SIZE"
}

struct ICloudKVP: Codable {
    static let freeTrialEndDate = "FREE_TRIAL_END_DATE"
}

struct MenuTitles {
    static let title = "Menu"
    static let move = "Move"
    static let moveCurrentWindow = "Move Current Window"
    static let support = "Support"
    static let webWindow = "New Web Window"
    static let localWindow = "Open Local File"
    static let infoWindow = "Info"
    static let quit = "Quit"
    static let moveTopLeft = "Top Left"
    static let moveTopRight = "Top Right"
    static let moveBottomLeft = "Bottom Left"
    static let moveBottomRight = "Bottom Right"
    static let requestAFeature = "Request a Feature"
    static let reportABug = "Report a Bug"
    
    static let saveLogs = "Save Logs"
    static let resetLogs = "Reset Logs"
    static let outOfDate = "Update Is Available"
    
    static let settings = "Settings"
    static let autoHideAddressBar = "Auto Hide Address Bar"
    static let useLastWindowSize = "Create Window With Last Used Size"
    static let reset = "Reset to default"
    
    static let addressBar = "Address Bar"
    static let controlCurrentAddressBar = "Control Current Address Bar"
    static let hideAddressBar = "Hide"
    static let showAddressBar = "Show"
    
    static let fromCopy = "Open From Copied Url"
    
    static let showPurchases = "Show Purchases"
}

struct AlertMessages {
    static let trialEnded =
    """
    If you have previously purchased SuperView please use the restore button
    """
}

struct AlertTitles {
    static let trialEnded = "Free trial has ended"
}

extension Notification {
    
    static func WebViewDirectionChange(windowId: String) -> Notification.Name {
        return Notification.Name("\(windowId)-WEBVIEW_DIRECTION_CHANGE")
    }
    
    static func WebViewUrlChange(windowId: String) -> Notification.Name {
        return Notification.Name("\(windowId)-WEBVIEW_DIRECTION_CHANGE")
    }
}
