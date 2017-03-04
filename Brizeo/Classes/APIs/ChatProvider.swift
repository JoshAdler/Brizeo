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
        guard let currentUser = UserProvider.shared.currentUser else {
            print("Error: can't register user in chat because current user is nil")
            return
        }
        
        let chatManager : ALChatManager = ALChatManager(applicationKey: Configurations.Applozic.appKey as NSString)
        let user = ALUser()
        
        user.displayName = currentUser.displayName
        user.userId = currentUser.objectId
        user.email = currentUser.email
        user.applicationId = Configurations.Applozic.appKey
        
        ALUserDefaultsHandler.setUserId(user.userId)
        ALUserDefaultsHandler.setEmailId(user.email)
        ALUserDefaultsHandler.setDisplayName(user.displayName)
        
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
