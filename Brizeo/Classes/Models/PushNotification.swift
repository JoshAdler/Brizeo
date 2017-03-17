//
//  PushNotification.swift
//  Brizeo
//
//  Created by Roman Bayik on 3/17/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit

class PushNotification: NSObject {

    // MARK: - Types
    
    enum JSONKeys: String {
        case userId = "userid"
        case type = "type"
    }
    
    // MARK: - Properties
    
    var userId: String?
    var type: NotificationType?
    
    var hasInfo: Bool {
        return userId != nil && type != nil
    }
    
    // MARK: - Init
    
    init(dict: [String: Any]) {
        
        self.userId = dict[JSONKeys.userId.rawValue] as? String
        
        if let typeStr = dict[JSONKeys.type.rawValue] as? String, let type = NotificationType(rawValue: typeStr) {
            self.type = type
        }
    }
}
