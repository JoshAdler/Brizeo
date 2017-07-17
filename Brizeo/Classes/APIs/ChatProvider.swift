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
    
    class func registerUserInChat(completionHandler: ((Bool) -> Void)?) {
        guard let currentUser = UserProvider.shared.currentUser else {
            print("Error: can't register user in chat because current user is nil")
            return
        }
        // TODO: customize chat view as it is possible 
        let chatManager : ALChatManager = ALChatManager(applicationKey: Configurations.Applozic.appKey as NSString)
        let user = ALUser()
        
        user.displayName = currentUser.shortName
        user.userId = currentUser.objectId
        user.email = currentUser.email
        user.applicationId = Configurations.Applozic.appKey
        
        if let url = currentUser.profileUrl {
            user.imageLink = url.absoluteString
        }
        
        ALUserDefaultsHandler.setUserId(user.userId)
        ALUserDefaultsHandler.setEmailId(user.email)
        ALUserDefaultsHandler.setDisplayName(user.displayName)
        
        chatManager.registerUser(user) { (response, error) in
            completionHandler?(error == nil)
        }
    }
    
    class func logout() {
        
        let registerUserClientService: ALRegisterUserClientService = ALRegisterUserClientService()
        
        registerUserClientService.logout { (response, error) in
            if error == nil {
                print("Successfully logged out from Applozic")
            } else {
                print("Failurlly logged out from Applozic")
                print("Error: \(error!.localizedDescription)")
            }
        }
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
        
        let DBHandler = ALDBHandler.sharedInstance()
        let messageDBService = ALMessageDBService()
        let message = ALMessage()
        
        message.contactIds = Configurations.Applozic.superUserId //super admin id
        message.to = Configurations.Applozic.superUserId//UserProvider.shared.currentUser!.objectId
        message.createdAtTime = NSNumber(value: Date().timeIntervalSince1970 * 1000.0)
        message.deviceKey = ALUserDefaultsHandler.getDeviceKeyString()
        message.sendToDevice = false
        message.shared = false
        message.fileMeta = nil
        message.key = "brizeo_welcome_message_\(UserProvider.shared.currentUser!.objectId)"
        message.delivered = false
        message.fileMetaKey = nil
        message.type = "4"
        message.status = NSNumber(value: 5)
        message.message = LocalizableString.ChatAdminWelcomeMessage.localizedStringWithArguments([UserProvider.shared.currentUser!.shortName])
        message.groupId = nil
        messageDBService.createMessageEntityForDBInsertion(with: message)
        
        do {
            try DBHandler?.managedObjectContext.save()
        } catch (_) {
            print("applozic error")
        }
    }
    
    class func createMatchingChat(with user: User) {
        
        /*
        let DBHandler = ALDBHandler.sharedInstance()
        let messageDBService = ALMessageDBService()
        let message = ALMessage()
        
        message.contactIds = user.objectId
        message.to = user.objectId
        message.createdAtTime = NSNumber(value: Date().timeIntervalSince1970 * 1000.0)
        message.deviceKey = ALUserDefaultsHandler.getDeviceKeyString()
        message.sendToDevice = true
        message.shared = true
        message.fileMeta = nil
        message.key = "brizeo_matching_message_\(user.objectId)_\(UserProvider.shared.currentUser!.objectId)"
        message.delivered = false
        message.fileMetaKey = nil
        message.type = "5" //DELIVERED_AND_READ
        message.message = LocalizableString.ItsAMatch.localizedString
        message.groupId = nil
        messageDBService.createMessageEntityForDBInsertion(with: message)
        
        do {
            try DBHandler?.managedObjectContext.save()
        } catch (_) {
            print("applozic error")
        }*/
        
        let message = ALMessageService.createCustomTextMessageEntitySend(to: user.objectId, withText: LocalizableString.ItsAMatch.localizedString)
        
        ALMessageService.sendMessages(message) { (message, error) in
            if error != nil {
                print("Applozic error took place for matching")
            }
        }
    }
    
    class func createMatchingChat(with userId: String) {
        
        let message = ALMessageService.createCustomTextMessageEntitySend(to: userId, withText: LocalizableString.ItsAMatch.localizedString)
        
        ALMessageService.sendMessages(message) { (message, error) in
            if error != nil {
                print("Applozic error took place for matching")
            }
        }
    }
    
    class func removeConversation(with user: User) {
        
        ALMessageService.deleteMessageThread(user.objectId, orChannelKey: nil) { (string, error) in
            if error != nil {
                print("Some error while removing conversation for user with id \(user.objectId). Reason: \(error!.localizedDescription)")
                return
            }
            
            print("Successfully removed conversation with user with id \(user.objectId)")
        }
    }
    
    class func totalUnreadCount() -> Int {
        
        if ALUserDefaultsHandler.isLoggedIn() {
            let userService = ALUserService()
            let totalUnreadCount = userService.getTotalUnreadCount().intValue
            
            return totalUnreadCount
        } else {
            return -1
        }
    }
}
