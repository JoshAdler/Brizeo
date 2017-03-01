//
//  ChatProvider.swift
//  Brizeo
//
//  Created by Roman Bayik on 3/1/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import Applozic

class ChatProvider: NSObject {

    // MARK: - Class methods
    //TODO: place this registration in the correct place
    class func registerUserInChat() {
        let chatManager : ALChatManager = ALChatManager(applicationKey: Configurations.Applozic.appKey as NSString)
        let user = ALUser()
        
        user.displayName = "Roman \(Date())"
        user.userId = UIDevice.current.identifierForVendor!.uuidString
        user.email = "email@gmail.com"
        user.applicationId = Configurations.Applozic.appKey
        
        ALUserDefaultsHandler.setUserId(user.userId)
        ALUserDefaultsHandler.setEmailId(user.email)
        ALUserDefaultsHandler.setDisplayName(user.displayName)
        
        // TODO: place real user data here
//        http://www.mk.ru/upload/entities/2017/02/02/articles/detailPicture/91/7e/d3/204815253_7796320.jpg
        chatManager.registerUser(user)
    }
    
    class func startChat(with userId: String?, from controller: UIViewController) {
        let chatManager : ALChatManager = ALChatManager(applicationKey: Configurations.Applozic.appKey as NSString)
        if userId != nil {
            chatManager.registerUserAndLaunchChat(nil, fromController: controller, forUser: "applozic")
        } else {
            chatManager.registerUserAndLaunchChat(nil, fromController: controller, forUser: userId)
        }
    }
}
