//
//  ActionCounter.swift
//  Brizeo
//
//  Created by Roman Bayik on 7/13/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

extension DefaultsKeys {
    static let lastSessionDate = DefaultsKey<Date?>("lastSessionDate")
    static let approveCount = DefaultsKey<Int>("approveCount")
    static let declineCount = DefaultsKey<Int>("declineCount")
}

let approveCountChangedNotification = "approveCountChangedNotification"
let declineCountChangedNotification = "declineCountChangedNotification"
let actionCounterIsResetNotification = "actionCounterIsResetNotification"

class ActionCounter: NSObject {

    // MARK: - Properties
    
    static let shared = ActionCounter()
    
    fileprivate var timer: Timer?
    
    // MARK: - Init
    
    private override init() {}
    
    var sessionDate: Date? {
        return Defaults[.lastSessionDate]
    }
    
    var totalCount: Int {
        return Defaults[.approveCount] + Defaults[.declineCount]
    }
    
    // MARK: - Private methods
    
    fileprivate func userDidAction() {
        
        guard sessionDate != nil, sessionDate!.timeIntervalSinceNow <= Configurations.General.timeToReset else { // set default values
            Defaults[.lastSessionDate] = Date()
            
            //reset counter
            Defaults[.approveCount] = 0
            Defaults[.declineCount] = 0
            
            // run reset timer
            ActionCounter.runResetTimer()
            
            return
        }
    }
    
    // MARK: - Class methods
    
    class func runResetTimer() {
        
        guard let sessionDate = shared.sessionDate else {
            return
        }
        
        guard sessionDate.timeIntervalSinceNow <= Configurations.General.timeToReset else {
            return
        }
        
//        let resetDate = Calendar.current.date(byAdding: .day, value: 1, to: sessionDate)
        let interval = Configurations.General.timeToReset - sessionDate.timeIntervalSinceNow
        
        shared.timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false, block: { (timer) in
            
            Helper.sendNotification(with: actionCounterIsResetNotification, object: nil, dict: nil)
        })
    }
    
    class func canDoAction(fromSearchController: Bool) -> Bool {
        
        if Configurations.General.shouldCountOnlySearch && !fromSearchController {
            return true
        }
        
        // check session
        guard let lastSessionDate = Defaults[.lastSessionDate] else {
            return true
        }
        
        // check date
        if lastSessionDate.timeIntervalSinceNow > Configurations.General.timeToReset { // should be reset
            return true
        }
        
        // check counter
        let approveCount = Defaults[.approveCount]
        let declineCount = Defaults[.declineCount]
        
        return approveCount + declineCount < Configurations.General.actionLimit
    }
    
    class func didApprove(fromSearchController: Bool) {
        
        if Configurations.General.shouldCountOnlySearch && !fromSearchController {
            return
        }
        
        shared.userDidAction()
        
        // increase counter
        Defaults[.approveCount] += 1
       
        Helper.sendNotification(with: approveCountChangedNotification, object: nil, dict: nil)
    }
    
    class func didDecline(fromSearchController: Bool) {
        
        if Configurations.General.shouldCountOnlySearch && !fromSearchController {
            return
        }
        
        shared.userDidAction()
        
        // increase counter
        Defaults[.declineCount] += 1

        Helper.sendNotification(with: declineCountChangedNotification, object: nil, dict: nil)
    }
}
