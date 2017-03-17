//
//  Notification.swift
//  Brizeo
//
//  Created by Monkey on 9/14/16.
//  Copyright © 2016 Kogi Mobile. All rights reserved.
//

import Crashlytics
import ObjectMapper

enum NotificationType: String {
    case newMatches = "newmatch"
    case momentsLikes = "momentslike"
}

class Notification: Mappable {

    // MARK: - Types
    
    enum JSONKeys: String {
        case objectId = "objectId"
        case pushType = "pushType"
        case receiveUser = "receiveUser"
        case sendUser = "sendUser"
        case moment = "moment"
        case createdAt = "createdAt"
    }
    
    // MARK: - Properties
    
    var objectId: String = "0"
    var receiverUser: User?
    var senderUser: User?
    var moment: Moment?
    var pushType: NotificationType!
    var createdAt: Date?

    // MARK: - Init
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        
        objectId <- map[JSONKeys.objectId.rawValue]
        receiverUser <- map[JSONKeys.receiveUser.rawValue]
        senderUser <- map[JSONKeys.sendUser.rawValue]
        moment <- map[JSONKeys.moment.rawValue]
        pushType <- (map[JSONKeys.pushType.rawValue], EnumTransform<NotificationType>())
        createdAt <- (map[JSONKeys.createdAt.rawValue], LastActiveDateTransform())
    }
}
