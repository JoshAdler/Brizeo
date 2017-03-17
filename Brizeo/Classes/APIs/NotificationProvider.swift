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

class NotificationProvider: NSObject {

    // MARK: - Types
    
    typealias NotificationsCompletion = (Result<[Notification]>) -> Void
    
    // MARK: - Properties
    
    static let shared = NotificationProvider()
    
    // MARK: - Class methods
    
    class func getNotification(for userId: String, completion: @escaping NotificationsCompletion) {
        
        let provider = MoyaProvider<APIService>()
        provider.request(.getNotifications(userId: userId)) { (result) in
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
        if let token = FIRInstanceID.instanceID().token(), let currentUser = UserProvider.shared.currentUser {
            currentUser.deviceToken = token
            UserProvider.updateUser(user: currentUser, completion: nil)
        }
    }
}
