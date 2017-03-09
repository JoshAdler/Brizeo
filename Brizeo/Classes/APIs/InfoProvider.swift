//
//  InfoProvider.swift
//  Brizeo
//
//  Created by Roman Bayik on 3/6/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import Moya

class InfoProvider: NSObject {
    
    // MARK: - Types
    
    typealias EmptyCompletion = (Result<Void>) -> Void
    
    // MARK: - Class methods
    
    class func notifyAdminAboutDownloads(count: Int, completion: EmptyCompletion?) {
        
        guard let user = UserProvider.shared.currentUser else {
            print("Error: Can't report moment without current user")
            completion?(.failure(APIError(code: 0, message: "Can't report moment without current user")))
            return
        }
        
        let provider = MoyaProvider<APIService>()
        provider.request(.notifyAdminAboutDownloads(userId: user.objectId, count: count)) { (result) in
            switch result {
            case .success(let response):
                
                guard response.statusCode == 200 else {
                    completion?(.failure(APIError(code: response.statusCode, message: nil)))
                    return
                }
                
                completion?(.success())
                break
            case .failure(let error):
                completion?(.failure(APIError(error: error)))
                break
            }
        }
    }
}
