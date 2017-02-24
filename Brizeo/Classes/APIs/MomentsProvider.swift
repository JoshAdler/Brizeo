//
//  MomentsProvider.swift
//  Brizeo
//
//  Created by Giovanny Orozco on 5/5/16.
//  Copyright © 2016 Kogi Mobile. All rights reserved.
//

import Foundation
import Parse
import Crashlytics

enum MomentsListType {
    case allMoments(userId: String)
    case myMatches(userId: String)
    case myMoments(userId: String)
}

struct MomentsProvider {

    // MARK: - Types
    
    typealias MomentsCompletion = (Result<[Moment]>) -> Void
    
    struct Constants {
        static let momentsLimitAmount = 20
    }
    
    fileprivate struct MomentsKey {
        static let SkipKey = "skip"
        static let SizeKey = "size"
        static let MomentId = "imageId"
    }
    
    // MARK: - Properties
    
    static func getMomentsList(_ momentsType: MomentsListType, sort: Bool, paginator: PaginationHelper, completion: @escaping MomentsCompletion) {
    
        switch momentsType {
        case .allMoments(let userId):
            if sort {
               getAllMomentsWithQuery(paginator: paginator,userId: userId, completion: completion)
            } else {
                getAllMoments(paginator: paginator, userId: userId, completion: completion)
            }
        case .myMatches(let userId):
            if sort {
                getMyMatchesMomentsNewest(paginator: paginator, userId: userId, completion: completion)
            } else {
                getMyMatchesMoments(paginator: paginator, userId: userId, completion: completion)
            }
        case .myMoments(let userId):
            if sort {
                getMyMomentsNewest(paginator: paginator, userId: userId, completion: completion)
            } else {
                getMyMoments(paginator: paginator, userId: userId, completion: completion)
            }
        }
    }
    
    static func getUsersWhoLikedMoment(_ moment: Moment, completion: @escaping (Result<[User]>) -> Void) {
    
        let params = [MomentsKey.MomentId : moment.objectId!]
        
        PFCloud.callFunction(inBackground: ParseFunction.GetMomentLikes.name, withParameters: params) { (objects, error) in
            
            if let error = error {
                
                completion(.failure(error.localizedDescription))
                
            } else if let users = objects as? [User] {
                
                completion(.success(users))
            }
        }
    }
    
    static func likeMoment(_ moment: Moment, completion: @escaping (Result<Bool>) -> Void) {
        let user = User.current()!
        CLSNSLogv("Attempting to user %@'s like of Moment %@", getVaList([user.objectId!, moment.objectId!]))
        // Make sure you can't like your own picture
        if(moment.user == user) {
            completion(.failure(LocalizableString.YouCantLikeYourOwnMoment.localizedString))
            return
        }
        
        let params : [String: AnyObject] = [UserParameterKey.UserIdKey : user.objectId! as AnyObject, MomentsKey.MomentId: moment.objectId! as AnyObject]
        PFCloud.callFunction(inBackground: ParseFunction.LikeMoment.name, withParameters: params) { (result, error) in
            
            if let error = error {
                
                completion(.failure(error.localizedDescription))
                
            } else {
                
                moment.likedByCurrentUser = true
                moment.numberOfLikes += 1
                completion(.success(true))
            }
        }
    }
    
    static func unlikeMoment(_ moment: Moment, completion: @escaping (Result<Bool>) -> Void) {
        
        let user = User.current()!
        CLSNSLogv("Attempting to user %@'s like of Moment %@", getVaList([user.objectId!, moment.objectId!]))
        // Make sure you can't like your own picture
        if(moment.user == user) {
            completion(.failure(LocalizableString.YouCantLikeYourOwnMoment.localizedString))
            return
        }
        
        let params : [String: AnyObject] = [UserParameterKey.UserIdKey : user.objectId! as AnyObject, MomentsKey.MomentId: moment.objectId! as AnyObject]
        PFCloud.callFunction(inBackground: ParseFunction.UnlikeMoment.name, withParameters: params) { (result, error) in
            
            if let error = error {
                
                completion(.failure(error.localizedDescription))
                
            } else {
                
                moment.likedByCurrentUser = false
                moment.numberOfLikes -= 1
                completion(.success(true))
            }
        }
    }
    
    static func createMomentWithImage(_ image: UIImage, andDescription description: String, forUser user: User, completion: @escaping (Result<Moment>) -> Void) {
        
        guard let imageData = UIImageJPEGRepresentation(image, 0.8) else {
            CLSNSLogv("ERROR: Can't save new MomentImage!", getVaList([]))
            completion(.failure(LocalizableString.UnableToSaveMoment.localizedString))
            return
        }
        
        let params: [String : AnyObject] = [UserParameterKey.UserIdKey : user.objectId! as AnyObject]
        
        PFCloud.callFunction(inBackground: ParseFunction.GetCountUserMoments.name, withParameters: params) { (result, error) in
            
            if let error = error {
                completion(.failure(error.localizedDescription))
            } else {
                if let limit = result as? Int {
                    if limit < Constants.momentsLimitAmount {
                        let moment = Moment()
                        guard let imageFile = PFFile(name: "upload.jpg", data: imageData) else {
                            completion(.failure("Can't create PFFile with image"))
                            return
                        }
                        
                        moment.momentUploadImages = imageFile
                        moment.momentDescription = description
                        moment.user = user
                        moment.numberOfLikes = 0
                        moment.readStatus = true
                        moment.saveInBackground(block: { (success, error) in
                            
                            if success {
                                CLSNSLogv("Successfully saved new Moment %@", getVaList([moment.objectId!]))
                                completion(.success(moment))
                                if user.superUser {
                                    let params: [String : AnyObject] = [UserParameterKey.UserIdKey : user.objectId! as AnyObject, MomentsKey.MomentId: moment.objectId! as AnyObject]
                                    PFCloud.callFunction(inBackground: ParseFunction.SuperUserMoment.name, withParameters: params) { (result, error) in
                                    }
                                }
                            } else {
                                CLSNSLogv("ERROR: Could not save new moment: %@", getVaList([error! as CVarArg]))
                                completion(.failure(LocalizableString.UnableToSaveMoment.localizedString))
                            }
                        })
                    } else {
                        completion(.failure(LocalizableString.MomentsLimit.localizedString))
                    }
                } else {
                    completion(.failure(LocalizableString.UnableToSaveMoment.localizedString))
                }
            }
        }
    }
    
    static func deleteMoment(_ moment: Moment, user: User, completion: @escaping (Result<Bool>) -> Void) {
        
        let params : [String: AnyObject] = [UserParameterKey.UserIdKey : user.objectId! as AnyObject, MomentsKey.MomentId: moment.objectId! as AnyObject]
        PFCloud.callFunction(inBackground: ParseFunction.DeleteMoment.name, withParameters: params) { (result, error) in
            
            if let error = error {
                
                completion(.failure(error.localizedDescription))
                
            } else {
                
                completion(.success(true))
            }
        }
    }
    
    static func userDidLikeMoment(_ moment: Moment, userId: String, completion: @escaping (Result<Bool>) -> Void) {
        
        let params : [String: AnyObject] = [UserParameterKey.UserIdKey : userId as AnyObject, MomentsKey.MomentId: moment.objectId! as AnyObject]
        PFCloud.callFunction(inBackground: ParseFunction.GetUserDidLikeMoment.name, withParameters: params) { (result, error) in
            
            if let liked = result as? Bool {
                
                completion(.success(liked))
                
            } else {
                
                completion(.success(false))
            }
        }
    }
    
    static func reportMoment(_ moment: Moment, user: User, completion: @escaping (Result<Bool>) -> Void) {
        
        let params : [String: AnyObject] = [UserParameterKey.UserIdKey : user.objectId! as AnyObject, MomentsKey.MomentId: moment.objectId! as AnyObject]
        PFCloud.callFunction(inBackground: ParseFunction.ReportMoment.name, withParameters: params) { (result, error) in
            
            if let error = error {
                
                completion(.failure(error.localizedDescription))
                
            } else {
                
                completion(.success(true))
            }
        }
    }
}

//MARK: - Private Methods
extension MomentsProvider {

    fileprivate static func getAllMoments(paginator: PaginationHelper, userId: String, completion: @escaping MomentsCompletion) {
        
        let params: [String : AnyObject] = [UserParameterKey.UserIdKey : userId as AnyObject,
                                            MomentsKey.SkipKey : paginator.totalElements as AnyObject,
                                            MomentsKey.SizeKey : paginator.elementsPerPage as AnyObject]
        
        PFCloud.callFunction(inBackground: ParseFunction.GetEverybodyMoments.name, withParameters: params) { (objects, error) in
            
            if let error = error {
                
                completion(.failure(error.localizedDescription))
                
            } else if let moments = objects as? [Moment] {
                
                for moment in moments {
                    
                    MomentsProvider.userDidLikeMoment(moment, userId: userId, completion: { (result) in
                        
                        switch result {
                            
                        case .success(let liked):
                            
                            moment.likedByCurrentUser = liked
                            break
                        case .failure(_):
                            break
                        }
                    })
                }
                
                let delayTime = DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: delayTime) {
                    completion(.success(moments))
                }
            }
        }
    }
    
    fileprivate static func getAllMomentsWithQuery(paginator: PaginationHelper, userId: String, completion: @escaping MomentsCompletion) {
        
        let query = Moment.query(paginator)
        query.findObjectsInBackground { (objects, error) in
            if let error = error {
                
                completion(.failure(error.localizedDescription))
                
            } else if let moments = objects as? [Moment] {
                
                for moment in moments {
                    
                    MomentsProvider.userDidLikeMoment(moment, userId: userId, completion: { (result) in
                        
                        switch result {
                            
                        case .success(let liked):
                            
                            moment.likedByCurrentUser = liked
                            break
                        case .failure(_):
                            break
                        }
                    })
                }
                
                let delayTime = DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: delayTime) {
                    completion(.success(moments))
                }
            }
        }
    }
    
    fileprivate static func getMyMatchesMoments(paginator: PaginationHelper, userId: String, completion: @escaping MomentsCompletion) {
        
        let params: [String : AnyObject] = [UserParameterKey.UserIdKey : userId as AnyObject,
                                            MomentsKey.SkipKey : paginator.totalElements as AnyObject,
                                            MomentsKey.SizeKey : paginator.elementsPerPage as AnyObject]
        
        PFCloud.callFunction(inBackground: ParseFunction.GetMatchesMoments.name, withParameters: params) { (objects, error) in
            
            if let error = error {
                
                completion(.failure(error.localizedDescription))
                
            } else if let moments = objects as? [Moment] {
                
                for moment in moments {
                    
                    MomentsProvider.userDidLikeMoment(moment, userId: userId, completion: { (result) in
                        
                        switch result {
                            
                        case .success(let liked):
                            
                            moment.likedByCurrentUser = liked
                            break
                        case .failure(_):
                            break
                        }
                    })
                }
                let delayTime = DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: delayTime) {
                    completion(.success(moments))
                }
            }
        }
    }
    
    fileprivate static func getMyMatchesMomentsNewest(paginator: PaginationHelper, userId: String, completion: @escaping MomentsCompletion) {
        
        let query = Moment.query(paginator)
        query.whereKey("user", matchesQuery: User.matchQuery(userId))
        query.findObjectsInBackground { (objects, error) in
            if let error = error {
                
                completion(.failure(error.localizedDescription))
                
            } else if let moments = objects as? [Moment] {
                
                for moment in moments {
                    
                    MomentsProvider.userDidLikeMoment(moment, userId: userId, completion: { (result) in
                        
                        switch result {
                            
                        case .success(let liked):
                            
                            moment.likedByCurrentUser = liked
                            break
                        case .failure(_):
                            break
                        }
                    })
                }
                
                let delayTime = DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: delayTime) {
                    completion(.success(moments))
                }
            }
        }
    }
    
    fileprivate static func getMyMoments(paginator: PaginationHelper, userId: String, completion: @escaping MomentsCompletion) {
        
        let query = Moment.queryMost(paginator)
        query.whereKey("user", matchesQuery: User.myQuery(userId))
        query.findObjectsInBackground { (objects, error) in
            if let error = error {
                
                completion(.failure(error.localizedDescription))
                
            } else if let moments = objects as? [Moment] {
                
                for moment in moments {
                    
                    MomentsProvider.userDidLikeMoment(moment, userId: userId, completion: { (result) in
                        
                        switch result {
                            
                        case .success(let liked):
                            
                            moment.likedByCurrentUser = liked
                            break
                        case .failure(_):
                            break
                        }
                    })
                }
                
                let delayTime = DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: delayTime) {
                    completion(.success(moments))
                }
            }
        }

    }
    
  
    
    fileprivate static func getMyMomentsNewest(paginator: PaginationHelper, userId: String, completion: @escaping MomentsCompletion) {
        
        let query = Moment.query(paginator)
        query.whereKey("user", matchesQuery: User.myQuery(userId))
        query.findObjectsInBackground { (objects, error) in
            if let error = error {
                
                completion(.failure(error.localizedDescription))
                
            } else if let moments = objects as? [Moment] {
                
                for moment in moments {
                    
                    MomentsProvider.userDidLikeMoment(moment, userId: userId, completion: { (result) in
                        
                        switch result {
                            
                        case .success(let liked):
                            
                            moment.likedByCurrentUser = liked
                            break
                        case .failure(_):
                            break
                        }
                    })
                }
                
                let delayTime = DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: delayTime) {
                    completion(.success(moments))
                }
            }
        }
    }
}
