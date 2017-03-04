//
//  Notification.swift
//  Brizeo
//
//  Created by Monkey on 9/14/16.
//  Copyright © 2016 Kogi Mobile. All rights reserved.
//

import Crashlytics
import Branch

class Notification: NSObject {

    // MARK: - Types
    
    enum JSONKeys: String {
        case objectId = "objectId"
        case readStatus = "readStatus"
        case receiveUserId = "receiveUserId"
        case sendUserId = "sendUserId"
        case momentsId = "momentsId"
        case newMatchId = "newMatchId"
        case pushType = "pushType"
    }
    
    // MARK: - Properties
    
    var objectId: String
    var readStatus: Bool
    var receiveUserId: String?
    var sendUserId: String?
    var momentsId: String?
    var newMatchId: String?
    var pushType: String!

    // MARK: - Init
    
    init(with JSON: [String: Any]) {
        
        // ids
        objectId = JSON[JSONKeys.objectId.rawValue] as! String
        receiveUserId = JSON[JSONKeys.receiveUserId.rawValue] as? String
        sendUserId = JSON[JSONKeys.sendUserId.rawValue] as? String
        momentsId = JSON[JSONKeys.momentsId.rawValue] as? String
        newMatchId = JSON[JSONKeys.newMatchId.rawValue] as? String
        
        readStatus = JSON[JSONKeys.readStatus.rawValue] as! Bool
        pushType = JSON[JSONKeys.pushType.rawValue] as! String
    }
}
