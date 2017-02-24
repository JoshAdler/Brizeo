//
//  PushNotificationManager.swift
//  Brizeo
//
//  Created by Arturo on 5/31/16.
//  Copyright © 2016 Kogi Mobile. All rights reserved.
//

import UIKit
import Parse

class PushNotificationManager: NSObject {

    // MARK: - Properties
    
    fileprivate static let privateInstance = PushNotificationManager()
    
    // MARK: - Static methods
    
    static func sharedInstance() -> PushNotificationManager {
        return PushNotificationManager.privateInstance
    }
    
    // MARK: - Public methods
    
    func sendPush(_ user : PFUser, text : String) {
        let push = PFPush()
        let pushQuery = PFInstallation.query()
        pushQuery!.whereKey("user", equalTo: user)
        push.setQuery(pushQuery as! PFQuery<PFInstallation>?) // Set our Installation query
        let data = ["alert":text,
                    "badge":"Increment",
                    "sound":Resources.pushNotificationSound]
        push.setData(data)
        push.sendInBackground()
    }
}
