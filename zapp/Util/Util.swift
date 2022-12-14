//
//  Util.swift
//  zapp
//
//  Created by Joe Manto on 9/8/21.
//

import Foundation
import Cocoa

func onDebug(_ debug: ()->()) {
    #if DEBUG
        debug()
    #endif
}

class Util {
    
    static func checkIfAppIsOutdatedIfNeeded(mockLocalVersion:String? = nil, mockAppStoreVersion:String? = nil, comp: ((Bool)->())?) {
        let lastUpdateCheck = Settings.shared.integer(forKey: Setting.lastAppUpdateCheck, log: true)
        let appIsOutDated = Settings.shared.integer(forKey: Setting.isOutDated, log: true)
        
        defer {
            Settings.shared.setValue(Date().timeIntervalSince1970, forKey: Setting.lastAppUpdateCheck, log: true)
        }
        
        // Need save the version that marked outdate vs current installed version
        // Check for diff
        guard appIsOutDated == 0 else {
            // If we already know the app is out of date no point in re checking
            return
        }
        
        // O if no value is in default. Which will cause the update check to run
        let lastCheck = Date(timeIntervalSince1970: TimeInterval(lastUpdateCheck))
        
        guard let url = URL(string: "https://itunes.apple.com/lookup?bundleId=com.Joseph-Manto.Cross") else {
            return
        }
        
        let minTimeToCheck: TimeInterval = {
            return 86400.0 // One Day
        }()
        
        let onFailure: (String) -> () = {
            Logging.shared.log(msg: $0, comp: "[Util]", type: .err)
            // Just in case we hit an error we don't want to keep showing out of date as it could be wrong
            Settings.setValue(false, forKey: Setting.isOutDated)
        }
        
        if lastCheck.advanced(by: minTimeToCheck).timeIntervalSince1970 <= Date().timeIntervalSince1970  {
            let task = URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
                guard error == nil else {
                    onFailure("checking app udate status \(String(describing: error?.localizedDescription))")
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse,
                    (200...299).contains(httpResponse.statusCode) else {
                        onFailure(" server error: got response code \((response as? HTTPURLResponse)?.statusCode ?? -1) ")
                    return
                }
                guard let mimeType = httpResponse.mimeType, mimeType == "text/javascript",
                      let data = data else {
                    onFailure("incorrect mime type or didn't get any data")
                    return
                }
                
                guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] else {
                    onFailure("unable to convert responce to json")
                    return
                }
            
                guard let results = json["results"] as? [Any],
                      var version = (results.first as? [String : Any])?["version"] as? String else {
                    onFailure("unable to get version")
                    return
                }
                
                guard var currentVersion = (Bundle.main.infoDictionary)?["CFBundleShortVersionString"] as? String else {
                    onFailure("Unable to get current app version")
                    return
                }
                
                if let mockLocalVersion = mockLocalVersion,
                   let mockAppStoreVersion = mockAppStoreVersion {
                    currentVersion = mockLocalVersion
                    version = mockAppStoreVersion
                }
                
                var isOutDated = false
                if (currentVersion != version) {
                    isOutDated = true
                    Settings.shared.setValue(true, forKey: Setting.isOutDated, log: true)
                }
                
                DispatchQueue.main.async {
                    comp?(isOutDated)
                }
                Logging.shared.log(msg: "[Util] was able to fetch Version data. Current Local Version \(currentVersion) App Store Version: \(version)")
            })
            task.resume()
        }
    }
    
    static func getUrlFromPasteBoard() -> URL? {
        if let possibleUrlString = NSPasteboard.general.string(forType: .URL),
           let url = URL(string: possibleUrlString),
           url.scheme != nil {
            
            return url
        }
        else if let possibleUrlString = NSPasteboard.general.string(forType: .string),
            let url = URL(string: possibleUrlString),
            url.scheme != nil {
            
            return url
        }
        return nil
    }
    
    static func increaseNumberOfAppRuns() -> Int {
        var numAppRuns = Settings.shared.integer(forKey: Setting.numAppRuns, log: true)
        numAppRuns += 1
        Settings.shared.setValue(numAppRuns, forKey: Setting.numAppRuns, log: true)
        return numAppRuns
    }
    
    static func attemptToFixUrl(urlString: String) -> URL? {
        let comps = URLComponents(string: urlString)
        
        var newUrlString = urlString
        if comps?.scheme == nil {
            newUrlString = "https://\(urlString)"
        }
        
        let url = URL(string: newUrlString)
        return url
    }
    
    static func isValidWebUrl(_ url: URL?) -> Bool {
        guard let url = url,
              url.scheme != nil else {
            return false
        }
        return true
    }
    
    static func showAlert(msg: String) {
        let alert = NSAlert()
        alert.messageText = "Invalid Url"
        alert.addButton(withTitle: "Ok")
        alert.runModal()
    }
    
    static func showStoreKitAlert(title: String, msg: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = msg
        alert.addButton(withTitle: "Ok")
        alert.runModal()
    }
}

extension Calendar {
    func numberOfDaysBetween(_ from: Date, and to: Date) -> Int {
        let fromDate = startOfDay(for: from)
        let toDate = startOfDay(for: to)
        let numberOfDays = dateComponents([.day], from: fromDate, to: toDate)
        
        return numberOfDays.day!
    }
}
