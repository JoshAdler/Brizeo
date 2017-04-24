//
//  User+Match.swift
//  Brizeo
//
//  Created by Arturo on 4/21/16.
//  Copyright © 2016 Kogi Mobile. All rights reserved.
//

import Foundation
import Crashlytics
import Moya

class MatchesProvider {
    
    // MARK: - Types
    
    typealias MatchUserCompletion = (Result<User>) -> Void
    typealias UsersCompletion = (Result<[User]>) -> Void
    typealias EmptyCompletion = (Result<Void>) -> Void
    
    // MARK: - Class methods
    
    class func approveMatch(for user: User, completion: @escaping MatchUserCompletion) {
        
        guard let currentUser = UserProvider.shared.currentUser else {
            print("Error: Can't approve match without current user")
            completion(.failure(APIError(code: 0, message: "Can't approve match without current user")))
            return
        }
        
        APIService.performRequest(request: .approveMatch(approverId: currentUser.objectId, userId: user.objectId)) { (result) in
            switch result {
            case .success(let response):
                
                guard response.statusCode == 200 else {
                    completion(.failure(APIError(code: response.statusCode, message: nil)))
                    return
                }
                
                do {
                    let status = try response.mapString()
                    
                    user.status = MatchingStatus(rawValue: Int(status)!)!
                    completion(.success(user))
                } catch (let error) {
                    completion(.failure(APIError(error: error)))
                }
                break
            case .failure(let error):
                completion(.failure(APIError(error: error)))
                break
            }
        }
    }
    
    class func declineMatch(for user: User, completion: @escaping MatchUserCompletion) {
        
        guard let currentUser = UserProvider.shared.currentUser else {
            print("Error: Can't decline match without current user")
            completion(.failure(APIError(code: 0, message: "Can't decline match without current user")))
            return
        }
        
        APIService.performRequest(request: .declineMatch(approverId: currentUser.objectId, userId: user.objectId)) { (result) in
            switch result {
            case .success(let response):
                
                guard response.statusCode == 200 else {
                    completion(.failure(APIError(code: response.statusCode, message: nil)))
                    return
                }
                
                do {
                    let status = try response.mapString()
                    
                    user.status = MatchingStatus(rawValue: Int(status)!)!
                    completion(.success(user))
                } catch (let error) {
                    completion(.failure(APIError(error: error)))
                }
                break
            case .failure(let error):
                completion(.failure(APIError(error: error)))
                break
            }
        }
    }
    
    class func getUsersForMatching(for user: User, completion: @escaping UsersCompletion) {
        
        guard let currentUser = UserProvider.shared.currentUser else {
            print("Error: Can't get users for matching without current user")
            completion(.failure(APIError(code: 0, message: "Can't get users for matching without current user")))
            return
        }
        
        APIService.performRequest(request: .getUsersForMatch(userId: currentUser.objectId)) { (result) in
            switch result {
            case .success(let response):
                
                guard response.statusCode == 200 else {
                    completion(.failure(APIError(code: response.statusCode, message: nil)))
                    return
                }
                
                do {
                    let users = try response.mapArray(User.self)
                    completion(.success(users))
                } catch (let error) {
                    completion(.failure(APIError(error: error)))
                }
                break
            case .failure(let error):
                completion(.failure(APIError(error: error)))
                break
            }
        }
    }
    
    class func getMatches(for user: User, completion: @escaping UsersCompletion) {
        
        guard let currentUser = UserProvider.shared.currentUser else {
            print("Error: Can't get matches without current user")
            completion(.failure(APIError(code: 0, message: "Can't get matches without current user")))
            return
        }
        
        APIService.performRequest(request: .getMatchesForUser(userId: currentUser.objectId)) { (result) in
            switch result {
            case .success(let response):
                
                guard response.statusCode == 200 else {
                    completion(.failure(APIError(code: response.statusCode, message: nil)))
                    return
                }
                
                do {
                    let users = try response.mapArray(User.self)
                    completion(.success(users))
                } catch (let error) {
                    completion(.failure(APIError(error: error)))
                }
                break
            case .failure(let error):
                completion(.failure(APIError(error: error)))
                break
            }
        }
    }
}
