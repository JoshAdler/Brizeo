//
//  NotificationProvider.swift
//  Brizeo
//
//  Created by Roman Bayik on 3/6/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import Moya

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
                //self.passions = passions.sorted(by: {$0.displayOrder < $1.displayOrder})
                // TODO: make a request and cache result
                //                                completion(.success())
                // save to cache
                break
            case .failure(let error):
                completion(.failure(APIError(error: error)))
                break
            }
        }
    }
}
