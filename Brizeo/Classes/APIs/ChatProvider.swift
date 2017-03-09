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
    
    class func registerUserInChat() {
        guard let currentUser = UserProvider.shared.currentUser else {
            print("Error: can't register user in chat because current user is nil")
            return
        }
        // TODO: customize chat view as it is possible 
        let chatManager : ALChatManager = ALChatManager(applicationKey: Configurations.Applozic.appKey as NSString)
        let user = ALUser()
        
        user.displayName = currentUser.displayName
        user.userId = currentUser.objectId
        user.email = currentUser.email
        user.applicationId = Configurations.Applozic.appKey
        
        if let url = currentUser.profileUrl {
            user.imageLink = url.absoluteString
        }
        
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
    
    class func createChatWithSuperuser() {
//        let channelService = ALChannelService()
//
//        channelService.createChannel("Chat with admin", orClientChannelKey: nil, andMembersList: [UserProvider.shared.currentUser!.objectId, "2aMOJP6zFh"], andImageLink: "http://fsb.zedge.net/scale.php?img=Mi84LzQvOC8xLTkzMzA3NjMtMjg0ODEyNC5qcGc&ctype=1&v=4&q=81&xs=620&ys=0&sig=9dbb4bdba5aeb86a6d79bdd7ff95d4f66a263319") { (channel, error) in
//            if error == nil {
//                print("Successfully created a chat")
//            }
//        }
    }
}
