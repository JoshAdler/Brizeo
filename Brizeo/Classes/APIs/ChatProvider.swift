//
//  ChatProvider.swift
//  Brizeo
//
//  Created by Roman Bayik on 3/1/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import Applozic
import SwiftyUserDefaults

extension DefaultsKeys {
    static let isChatWithAdminCreated = DefaultsKey<Bool>("isChatWithAdminCreated")
}

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
//        if userId != nil {
            chatManager.registerUserAndLaunchChat(nil, fromController: controller, forUser: userId)
//        } else {
//            chatManager.registerUserAndLaunchChat(nil, fromController: controller, forUser: userId)
//        }
    }
    
    class func createChatWithSuperuser() {
        
        if Defaults[.isChatWithAdminCreated] == true {
            return
        }
        
        let DBHandler = ALDBHandler.sharedInstance()
        let messageDBService = ALMessageDBService()
        let message = ALMessage()
        
        message.contactIds = UserProvider.shared.currentUser!.objectId //super admin id
        message.to = "CBAB6i9aKq"
        message.createdAtTime = NSNumber(value: Date().timeIntervalSince1970 * 1000.0)
        message.deviceKey = ALUserDefaultsHandler.getDeviceKeyString()
        message.sendToDevice = false
        message.shared = false
        message.fileMeta = nil
        message.status = 1 // read status  [NSNumber numberWithInt:READ];
        message.key = "welcome to brizeo message"
        message.delivered = false
        message.fileMetaKey = "";//4
        message.contentType = 0
        message.status = 5 //[NSNumber numberWithInt:DELIVERED_AND_READ];
        
//        if(channelKey!=nil) //Group's Welcome
//        {
//            theMessage.type=@"101";
//            //Replace your welcome message
//            theMessage.message=@"You have created a new group, Say something!!";
//            theMessage.groupId = channelKey;
//        }
//        else //Individual's Welcome
//        {
            message.type = "4"//@"4";
            //Replace your welcome message
            message.message = "Welcome to Applozic! Drop a message here or contact us at devashish@applozic.com for any queries. Thanks"//3
            message.groupId = nil
        //        }
        messageDBService.createMessageEntityForDBInsertion(with: message)
        do {
            try DBHandler?.managedObjectContext.save()
            Defaults[.isChatWithAdminCreated] = true
        } catch (let error) {
            print("applozic error")
        }
    }
}
