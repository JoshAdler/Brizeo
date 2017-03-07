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
    
    // MARK: - Class methods
    
    class func approveMatch(for user: User, completion: @escaping MatchUserCompletion) {
        
        guard let currentUser = UserProvider.shared.currentUser else {
            print("Error: Can't approve match without current user")
            completion(.failure(APIError(code: 0, message: "Can't approve match without current user")))
            return
        }
        
        let provider = MoyaProvider<APIService>()
        provider.request(.approveMatch(approverId: currentUser.objectId, userId: user.objectId)) { (result) in
            switch result {
            case .success(let response):
                
                guard response.statusCode == 200 else {
                    completion(.failure(APIError(code: response.statusCode, message: nil)))
                    return
                }
                
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
    
    class func declineMatch(for user: User, completion: @escaping MatchUserCompletion) {
        
        guard let currentUser = UserProvider.shared.currentUser else {
            print("Error: Can't decline match without current user")
            completion(.failure(APIError(code: 0, message: "Can't decline match without current user")))
            return
        }
        
        let provider = MoyaProvider<APIService>()
        provider.request(.declineMatch(approverId: currentUser.objectId, userId: user.objectId)) { (result) in
            switch result {
            case .success(let response):
                
                guard response.statusCode == 200 else {
                    completion(.failure(APIError(code: response.statusCode, message: nil)))
                    return
                }
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
    
    class func getUsersForMatching(for user: User, completion: @escaping UsersCompletion) {
        
        guard let currentUser = UserProvider.shared.currentUser else {
            print("Error: Can't get users for matching without current user")
            completion(.failure(APIError(code: 0, message: "Can't get users for matching without current user")))
            return
        }
        
        let provider = MoyaProvider<APIService>()
        provider.request(.getUsersForMatch(userId: currentUser.objectId)) { (result) in
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
        
        let provider = MoyaProvider<APIService>()
        provider.request(.getMatchesForUser(userId: currentUser.objectId)) { (result) in
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
    
//    static func getPotentialMatchesForUser(_ user: User, completion:@escaping ((Result<[User]>) -> Void)) {
//        
//        let params = [UserParameterKey.UserIdKey : user.objectId]
//        
//        PFCloud.callFunction(inBackground: ParseFunction.PossibleMatches.name, withParameters: params, block: { (result, error) in
//            
//            if(error != nil) {
//                completion(.failure(LocalizableString.MessageErrorFetchingMatches.localizedString))
//                return
//            }
//            
//            var users:[User] = []
//            var males:[User] = []
//            var females:[User] = []
//            var others:[User] = []
//            let pfObjects = result as! [AnyObject]
//            
//            for object in pfObjects {
//                
//                var user : User?
//                if object is [String : AnyObject] {
//                    user = User.fromParseUser(object as! [String : AnyObject])!
//                } else {
//                    user = object as? User
//                }
//                
//                if let user = user, let gender = user.gender {
//                    switch gender {
//                    case Gender.Man.rawValue:
//                        males.append(user)
//                    case Gender.Woman.rawValue:
//                        females.append(user)
//                    default:
//                        others.append(user)
//                    }
//                }
//            }
//            // combine the 2 lists alternately and tack on the undefineds at the end
//            let maleFemaleCount = males.count + females.count
//            if maleFemaleCount > 0 {
//                for ind in 0...(maleFemaleCount - 1) {
//                    // check emptiness
//                    if (males.isEmpty) {
//                        users.append(contentsOf: females)
//                        break
//                    } else if (females.isEmpty) {
//                        users.append(contentsOf: males)
//                        break
//                    } else {
//                        // neither is empty, do normal behavior
//                        if ind % 2 == 0 {
//                            // male if even
//                            users.append(males.removeLast())
//                        } else {
//                            // female if odd
//                            users.append(females.removeLast())
//                        }
//                    }
//                }
//            }
//            // tack on the undefined values
//            users.append(contentsOf: others)
//            print(users.count)
//            let user = User.current()
//            
//            if user != nil {
//                print(user!)
//            }
//            
//            var preferences: Preferences
//            preferences = Preferences()
//            PreferencesProvider.getUserMatchPrefs(user!) { (result) in
//                
//                switch result {
//                case .success(let value):
//                    preferences = value
//                    print(preferences)
//                    users = getUsersWithinLocation(preferences, users: users)
//                    users = sortUsersBasedonDistance(users)
//                    
//                    completion(.success(users))
//                    break
//                case .failure(let error):
//                    print(error)
//                    break
//                }
//            }
//
//           
//            
//        })
//    }
    
//    static func getUsersWithinLocation(_ preferences: Preferences, users: [User]) -> [User]{
//        guard users.count > 1 else { return users }
//        
//        print(users.count)
//        let searhDistance = preferences.searchDistance
//        let fromLocation = CLLocation(latitude:  preferences.searchLocation.latitude,longitude:  preferences.searchLocation.longitude)
//        var searchedUsers:[User] = []
//        
//        for user in users {
//            print(user)
//            if((user.location == nil)) {
//                continue
//            }
//            let toLocation = CLLocation(latitude: (user.location?.latitude)!, longitude: (user.location?.longitude)!)
//            let distance = fromLocation.distance(from: toLocation) * Configurations.Dimentions.milesPerMeter
//            if distance < searhDistance {
//                searchedUsers.append(user)
//            }
//        }
//        print(searchedUsers.count)
//        return searchedUsers
//    }
    
    static func sortUsersBasedonDistance(_ users: [User]) -> [User]{
        guard users.count > 1 else { return users }
        
        var tempUsers: [User] = users
//        for i in 1..<tempUsers.count{
//            var y = i
//            while y > 0 && getDistanceToAnotherUser(tempUsers[y]) < getDistanceToAnotherUser(tempUsers[y - 1]){
//                swap(&tempUsers[y-1], &tempUsers[y])
//                y -= 1
//            }
//        }
        return tempUsers
    }
    
    static func user(_ currentUser: User, didLikeUser match: User, completion: @escaping ((Result<Bool>) -> Void)) {
        
//        let params = ["userId" : currentUser.objectId, "targetId" : match.objectId!]
//        PFCloud.callFunction(inBackground: ParseFunction.LikeUser.name, withParameters: params, block: { (result, error) in
//            if(error != nil) {
//                CLSNSLogv("ERROR: Unable to register Like", getVaList([]))
//                completion(.failure("Unable to register vote"))
//                return
//            }
//            if let mutualMatch = result as? [String:Bool] {
//                CLSNSLogv("Is Mutual Match? %d", getVaList([mutualMatch["match"]! as CVarArg]))
//                completion(.success(mutualMatch["match"]! as Bool))
//                self.changeNotificationReadStatus(currentUser, didLikeUser: match)
//            }
//        })
    }
    
//    static func changeNotificationReadStatus(_ currentUser: User, didLikeUser match: User) {
//        let query = PFQuery(className: "Notification")
//        query.whereKey("receiveUser", equalTo: currentUser)
//        query.whereKey("sendUser", equalTo: match)
//        query.findObjectsInBackground { (notifications, error) in
//            if error == nil {
//                if notifications?.count > 0 {
//                    for notification in notifications! {
//                        notification["readStaus"] = true
//                        notification.saveInBackground()
//                    }
//                    NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: LocalizableString.ItsAMatch.localizedString), object: nil, userInfo: ["matchedUser": match])
//                } else {
//                    let queryUser = PFQuery(className: "Preferences")
//                    queryUser.whereKey("user", equalTo: match)
//                    queryUser.findObjectsInBackground(block: { (objects, error) in
//                        if error == nil {
//                            let object = objects![0]
//                            if let item = object["newMatch"] , item as! Bool == false {
//                                NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: LocalizableString.ItsAMatch.localizedString), object: match)
//                            } else {
//                                let likePush = PFObject(className: "Notification")
//                                likePush["PushType"] = PushType.Match.localizedString
//                                likePush["sendUser"] = User.current()!
//                                likePush["receiveUser"] = match
//                                likePush["readStaus"] = false
//                                likePush["momentId"] = "0"
//                                likePush.saveEventually { (success, error) in
//                                    if success {
//                                        let queryIn = PFInstallation.query()
//                                        let data = [
//                                            "alert": LocalizableString.SomebodyMatchYou.localizedStringWithArguments([currentUser.displayName]),
//                                            "badge": "Increment",
//                                            "sound": "default",
//                                            "push_type": PushType.Match.localizedString,
//                                            "user_id": (User.current()?.objectId)! as String]
//                                        
//                                        queryIn?.whereKey("user", equalTo: match)
//                                        do {
//                                            try PFPush.sendData(to: queryIn! as! PFQuery<PFInstallation>, withData: data)
//                                        } catch {
//                                            
//                                        }
//                                    } else if error != nil {
//                                        print(error!)
//                                    }
//                                }
//                            }
//                        }
//                    })
//                }
//            }
//        }
//    }
    
    static func user(_ currentUser: User, didPassUser match: User, completion: @escaping ((Result<Void>) -> Void)) {
        
//        let params = ["userId" : currentUser.objectId!, "targetId" : match.objectId!]
//        
//        PFCloud.callFunction(inBackground: ParseFunction.PassUser.name, withParameters: params, block: { (result, error) in
//            if(error != nil) {
//                CLSNSLogv("ERROR: Unable to register Pass", getVaList([]))
//                completion(.failure("Unable to register vote"))
//                return
//            }
//            completion(.success())
//        })
    }
    
    static func didUser(_ currentUser: User, alreadyVoteOnUser user:User, completion: @escaping (Result<Bool>) -> Void) {
        
//        let query = PFQuery(className: "Vote")
//        query.whereKey("from", equalTo: currentUser.objectId)
//        query.whereKey("to", equalTo: user.objectId)
//        
//        query.findObjectsInBackground { (result, error) in
//            if(error != nil && result != nil) {
//                completion(.failure("Unable to retrieve votes"))
//                return
//            }
//            
//            if(result!.isEmpty) {
//                completion(.success(false))
//            } else {
//                completion(.success(true))
//            }
//        }
    }
    
    static func getUserMatches(_ userId: String, paginater: PaginationHelper, completion:@escaping (Result<[User]>) -> Void) {
    
        
//        let query = User.matchQuery(userId)
//        query.order(byAscending: "displayName")
//        query.skip = paginater.totalElements
//        query.limit = 100
//
//        query.findObjectsInBackground { (objects, error) in
//            if let err = error {
//                print(err)
//                completion(.failure(error!.localizedDescription))
//            } else {
//                let users = objects as! [User]
//                completion(.success(users))
//            }
//        }
        
    }
    
    //Limit overcome
    static func getUserMatchesAlt(_ userId: String, mode: Int, completion:@escaping (Result<[User]>) -> Void) {
        
        
//        let query = User.matchQueryAlt(userId, mode: mode)
//        query.order(byDescending: "lastActiveTime")
//    
//        
//        
//        query.findObjectsInBackground { (objects, error) in
//            if let err = error {
//                print(err)
//                completion(.failure(error!.localizedDescription))
//            } else {
//                let users = objects as! [User]
//                completion(.success(users))
//            }
//        }
        
    }
    

}
