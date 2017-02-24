//
//  Notification.swift
//  Brizeo
//
//  Created by Monkey on 9/14/16.
//  Copyright © 2016 Kogi Mobile. All rights reserved.
//

import Parse
import Crashlytics
import Branch

class Notification: PFObject, PFSubclassing {

    // MARK: - Properties
    
    @NSManaged var sendUser: User
    @NSManaged var receiveUser: User
    @NSManaged var PushType: String
    @NSManaged var readStaus : Bool
    @NSManaged var momentId: String
    
    // MARK: - Static methods
    
    static func parseClassName() -> String {
        return "Notification"
    }
}
