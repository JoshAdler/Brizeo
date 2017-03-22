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
    case wantsToMatch = "wantsToMatch"
    case momentsLikes = "momentslike"
    
    var soundTitle: String? {
        switch self {
        case .newMatches, .wantsToMatch:
            return "sound_matches"
        case .momentsLikes:
            return "sound_likes"
        }
    }
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
        case updatedAt = "updatedAt"
        case user = "user"
        case isAlreadyViewed = "isAlreadyViewed"
    }
    
    // MARK: - Properties
    
    var objectId: String = "0"
    var receiverUser: User?
    var senderUser: User?
    var moment: Moment?
    var pushType: NotificationType!
    var createdAt: Date?
    var updatedAt: Date?
    var isAlreadyViewed: Bool = false
    
    var shortTime: String? {
        
        guard let createdAt = createdAt else {
            return nil
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: createdAt)
    }
    
    // MARK: - Init
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        
        objectId <- map[JSONKeys.objectId.rawValue]
        receiverUser <- map[JSONKeys.receiveUser.rawValue]
        senderUser <- map[JSONKeys.user.rawValue]
        moment <- map[JSONKeys.moment.rawValue]
        pushType <- (map[JSONKeys.pushType.rawValue], EnumTransform<NotificationType>())
        createdAt <- (map[JSONKeys.createdAt.rawValue], LastActiveDateTransform())
        updatedAt <- (map[JSONKeys.updatedAt.rawValue], LastActiveDateTransform())
        isAlreadyViewed <- map[JSONKeys.isAlreadyViewed.rawValue]
    }
}
