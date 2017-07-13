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

class ActionCounter: NSObject {

    // MARK: - Properties
    
     static let shared = ActionCounter()
    
    // MARK: - Init
    
    private override init() {}
    
    // MARK: - Private methods
    
    fileprivate func userDidAction() {
        
        if Defaults[.lastSessionDate] == nil {
            Defaults[.lastSessionDate] = Date()
            
            //reset counter
            Defaults[.approveCount] = 0
            Defaults[.declineCount] = 0
        }
    }
    
    // MARK: - Class methods
    
    class func canDoAction(fromSearchController: Bool) -> Bool {
        
        if Configurations.General.shouldCountOnlySearch && !fromSearchController {
            return true
        }
        
        // check session
        guard let lastSessionDate = Defaults[.lastSessionDate] else {
            return true
        }
        
        // check date
        if lastSessionDate.timeIntervalSinceNow > 86400 { // should be reset
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
