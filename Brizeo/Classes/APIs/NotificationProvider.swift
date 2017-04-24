//
//  NotificationProvider.swift
//  Brizeo
//
//  Created by Roman Bayik on 3/6/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import Moya
import Firebase

let shouldReloadNotifications = "shouldReloadNotifications"

class NotificationProvider: NSObject {

    // MARK: - Types
    
    typealias NotificationsCompletion = (Result<[Notification]>) -> Void
    
    // MARK: - Properties
    
    static let shared = NotificationProvider()
    var currentToken: String?
    
    // MARK: - Class methods
    
    class func getNotification(for userId: String, completion: @escaping NotificationsCompletion) {
        
        APIService.performRequest(request: .getNotifications(userId: userId)) { (result) in
            switch result {
            case .success(let response):
                
                guard response.statusCode == 200 else {
                    completion(.failure(APIError(code: response.statusCode, message: nil)))
                    return
                }
                
                do {
                    let notifications = try response.mapArray(Notification.self)
                    completion(.success(notifications))
                }
                catch (let error) {
                    completion(.failure(APIError(error: error)))
                }
                break
            case .failure(let error):
                completion(.failure(APIError(error: error)))
                break
            }
        }
    }
    
    class func updateCurrentUserToken() {
        if let token = NotificationProvider.shared.currentToken, let currentUser = UserProvider.shared.currentUser {
            currentUser.deviceToken = token
            UserProvider.updateUser(user: currentUser, completion: nil)
        } else {
            if UserProvider.shared.currentUser == nil {
                print("no user")
            } else {
                print("no token")
            }
        }
    }
    
    class func updateNotification(notification: Notification, completion: ((Result<Notification>) -> Void)?) {
        
        APIService.performRequest(request: .updateNotification(notification: notification)) { (result) in
            switch result {
            case .success(let response):
                
                guard response.statusCode == 200 else {
                    completion?(.failure(APIError(code: response.statusCode, message: nil)))
                    return
                }
                
                completion?(.success(notification))
                print("successfully updated notification")
                
                break
            case .failure(let error):
                completion?(.failure(APIError(error: error)))
                break
            }
        }
    }
    
    class func markNotificationAsAlreadyViewed(_ notification: Notification, completion: ((Result<Notification>) -> Void)?) {
        
        notification.isAlreadyViewed = true
        
        updateNotification(notification: notification, completion: completion)
    }
    
    class func operatePush(_ notification: PushNotification) {
        
        if notification.type == .newMatches { // matched
            
            guard let userId = notification.userId else {
                return
            }
            
            // load user data
            UserProvider.getUserWithStatus(for: userId, completion: { (result) in
                
                switch(result) {
                case .success(let user):
                    
                    if let currentNotification = Helper.currentTabNavigationController() {
                        Helper.showMatchingCard(with: user, from: currentNotification, true)
                    }
                    
                    break
                case .failure(let error):
                    print("Error during getting user by \(userId) for push matching: \(String(describing: error.errorDescription))")
                    break
                default:
                    break
                }
            })

        } else { // likes
            
            // play sound
            let isSoundEnables = PreferencesProvider.shared.currentUserPreferences?.isNotificationsMomentsLikeOn ?? true
            
            if isSoundEnables {
                Helper.playSound(title: NotificationType.momentsLikes.soundTitle)
            }
        }
        
        // reload notification controller content
        Helper.sendNotification(with: shouldReloadNotifications, object: nil, dict: ["type": notification.type ?? .momentsLikes])
    }
}
