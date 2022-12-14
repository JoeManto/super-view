//
//  FreeTrialController.swift
//  SuperWindow
//
//  Created by Joe Manto on 10/30/21.
//

import Foundation

class FreeTrialController {
    
    private var endDate: TimeInterval!
    
    init() {
        self.endDate = self.setupFreeTrialIfNeeded()
    }
    
    func updateTrial() {
        guard Settings.shared.hasFullAccess() == false else {
            Settings.shared.set(1, forKey: Setting.freeTrialAccess)
            return
        }
        
        if self.endDate < Date().timeIntervalSince1970 {
            Settings.shared.set(0, forKey: Setting.freeTrialAccess)
        }
        else {
            Settings.shared.set(1, forKey: Setting.freeTrialAccess)
        }
    }
    
    private func setupFreeTrialIfNeeded() -> TimeInterval {
        guard Settings.shared.hasFullAccess() == false else {
            return -1
        }
        
        let localEndDate = Settings.shared.value(forKey: Setting.freeTrialEndDate) as? TimeInterval
        
        if localEndDate == nil {
            // Check to see if a kvp exists already on icloud if so set the local to that
            if let icloudDate = getICloudEndDate(), icloudDate > 0 {
                Logging.shared.log(msg: "Assigned Trial Date-i", comp: "[FreeTrialController]")
                Settings.shared.set(icloudDate, forKey: Setting.freeTrialEndDate)
                return icloudDate
            }
            // We don't have a end date set on icloud or local. Create a new one
            else {
                let newDate = getNewEndDate()
                Settings.shared.set(newDate, forKey: Setting.freeTrialEndDate)
                setICloudEndDate(endDate: newDate)
                Logging.shared.log(msg: "Trial Date Never Assigned. Assigned New Date Ending: \(newDate)", comp: "[FreeTrialController]")
                return newDate
            }
        }
        
        return localEndDate!
    }
    
    private func getICloudEndDate() -> TimeInterval? {
        return NSUbiquitousKeyValueStore.default.double(forKey: ICloudKVP.freeTrialEndDate)
    }
    
    private func setICloudEndDate(endDate: TimeInterval) {
        NSUbiquitousKeyValueStore.default.set(endDate, forKey: ICloudKVP.freeTrialEndDate)
    }
    
    private func getNewEndDate() -> TimeInterval {
        let endDate = Date().advanced(by: TimeInterval(TRIAL_LENGTH))
        return endDate.timeIntervalSince1970
    }
}
