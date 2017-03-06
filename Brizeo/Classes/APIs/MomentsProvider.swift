//
//  MomentsProvider.swift
//  Brizeo
//
//  Created by Giovanny Orozco on 5/5/16.
//  Copyright © 2016 Kogi Mobile. All rights reserved.
//

import Foundation
import Crashlytics
import Moya
import SDWebImage

enum MomentsListType {
    case allMoments
    case myMatches(userId: String)
    case myMoments(userId: String)
}

enum MomentsSortingFlag: String {
    case newest = "updateAt"
    case popular = "popular"
    
    init(with index: Int) {
        if index == 1 {
            self = .popular
        } else {
            self = .newest
        }
    }
}

class MomentsProvider {

    // MARK: - Types
    
    typealias MomentsCompletion = (Result<[Moment]>) -> Void
    typealias MomentCompletion = (Result<Moment>) -> Void
    typealias MomentLikersCompletion = (Result<[User]>) -> Void
    
    struct Constants {
        static let momentsLimitAmount = 20
    }
    
    fileprivate struct MomentsKey {
        static let SkipKey = "skip"
        static let SizeKey = "size"
        static let MomentId = "imageId"
    }
    
    // MARK: - Class methods
    
    class func preloadMomentPictures(moments: [Moment]) {
        let urls = moments.filter({ $0.imageUrl != nil }).map({ $0.imageUrl })
        SDWebImagePrefetcher.shared().prefetchURLs(urls)
    }
    
    class func getMoments(for userId: String, sortingFlag: MomentsSortingFlag, filterFlag: String?, completion: @escaping MomentsCompletion) {
        
        let provider = MoyaProvider<APIService>()
        provider.request(.getMoments(userId: userId, sortingFlag: sortingFlag, filterFlag: filterFlag ?? "all")) { (result) in
            switch result {
            case .success(let response):
//                completion(.success())
                break
            case .failure(let error):
                //completion(.failure(error.localizedDescription))
                break
            }
        }
    }
    
    class func getAllMoments(sortingFlag: MomentsSortingFlag, filterFlag: String?, completion: @escaping MomentsCompletion) {
        
        let provider = MoyaProvider<APIService>()
        provider.request(.getAllMoments(sortingFlag: sortingFlag, filterFlag: filterFlag ?? "all")) { (result) in
            switch result {
            case .success(let response):
                
                guard response.statusCode == 200 else {
                    completion(.failure(APIError(code: response.statusCode, message: nil)))
                    return
                }
                
                do {
                    let moments = try response.mapArray(Moment.self)
                    completion(.success(moments))
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
    
    class func getMatchedMoments(userId: String, sortingFlag: MomentsSortingFlag, filterFlag: String?, completion: @escaping MomentsCompletion) {
        
        let provider = MoyaProvider<APIService>()
        provider.request(.getMatchedMoments(userId: userId, sortingFlag: sortingFlag, filterFlag: filterFlag ?? "all")) { (result) in
            switch result {
            case .success(let response):
                //                completion(.success())
                break
            case .failure(let error):
                completion(.failure(APIError(error: error)))
                break
            }
        }
    }
    
    class func create(new moment: Moment, completion: @escaping MomentCompletion) {
        
        let provider = MoyaProvider<APIService>()
        provider.request(.createNewMoment(moment: moment)) { (result) in
            switch result {
            case .success(let response):
//                                completion(.success())
                break
            case .failure(let error):
                completion(.failure(APIError(error: error)))
                break
            }
        }
    }
    
    class func delete(moment: Moment, completion: @escaping MomentCompletion) {
        
        guard let user = UserProvider.shared.currentUser else {
            print("Error: Can't delete moment without current user")
            completion(.failure(APIError(code: 0, message: "Can't delete moment without current user")))
            return
        }
        
        let provider = MoyaProvider<APIService>()
        provider.request(.deleteMoment(moment: moment, userId: user.objectId)) { (result) in
            switch result {
            case .success(let response):
                completion(.success(moment))
                break
            case .failure(let error):
                completion(.failure(APIError(error: error)))
                break
            }
        }
    }
    
    //TODO: user everywhere this solution like MomentCompletion
    class func getLikers(for moment: Moment, completion: @escaping MomentLikersCompletion) {
        
        let provider = MoyaProvider<APIService>()
        provider.request(.getLikersForMoment(moment: moment)) { (result) in
            switch result {
            case .success(let response):
                //                                completion(.success())
                break
            case .failure(let error):
                completion(.failure(APIError(error: error)))
                break
            }
        }
    }

    class func report(moment: Moment, completion: @escaping MomentCompletion) {
        
        guard let user = UserProvider.shared.currentUser else {
            print("Error: Can't report moment without current user")
            completion(.failure(APIError(code: 0, message: "Can't report moment without current user")))
            return
        }
        
        let provider = MoyaProvider<APIService>()
        provider.request(.reportMoment(moment: moment, reporterId: user.objectId)) { (result) in
            switch result {
            case .success(let response):
                completion(.success(moment))
                break
            case .failure(let error):
                completion(.failure(APIError(error: error)))
                break
            }
        }
    }
    
    class func like(moment: Moment, completion: @escaping MomentCompletion) {
        
        guard let user = UserProvider.shared.currentUser else {
            print("Error: Can't like moment without current user")
            completion(.failure(APIError(code: 0, message: "Can't like moment without current user")))
            return
        }
        
        let provider = MoyaProvider<APIService>()
        provider.request(.likeMoment(moment: moment, userId: user.objectId)) { (result) in
            switch result {
            case .success(let response):
                
                guard response.statusCode == 200 else {
                    completion(.failure(APIError(code: response.statusCode, message: nil)))
                    return
                }
                
                moment.isLikedByCurrentUser = true
                completion(.success(moment))
                break
            case .failure(let error):
                completion(.failure(APIError(error: error)))
                break
            }
        }
    }
    
    class func unlike(moment: Moment, completion: @escaping MomentCompletion) {
        
        guard let user = UserProvider.shared.currentUser else {
            print("Error: Can't unlike moment without current user")
            completion(.failure(APIError(code: 0, message: "Can't unlike moment without current user")))
            return
        }
        
        let provider = MoyaProvider<APIService>()
        provider.request(.unlikeMoment(moment: moment, userId: user.objectId)) { (result) in
            switch result {
            case .success(let response):
                
                guard response.statusCode == 200 else {
                    completion(.failure(APIError(code: response.statusCode, message: nil)))
                    return
                }
                
                moment.isLikedByCurrentUser = false
                completion(.success(moment))
                break
            case .failure(let error):
                completion(.failure(APIError(error: error)))
                break
            }
        }
    }
    
    //TODO: check to be sure that the current user can't like his moment
    
    class func getMoments(with type: MomentsListType, sortingFlag: MomentsSortingFlag, filterPassion: Passion?, paginator: PaginationHelper, completion: @escaping MomentsCompletion) {
        
        switch type {
        case .allMoments:
            getAllMoments(sortingFlag: sortingFlag, filterFlag: filterPassion?.objectId, completion: completion)
        case .myMatches(let userId):
            getMatchedMoments(userId: userId, sortingFlag: sortingFlag, filterFlag: filterPassion?.objectId, completion: completion)
        case .myMoments(let userId):
            getMoments(for: userId, sortingFlag: sortingFlag, filterFlag: filterPassion?.objectId, completion: completion)
        }
    }
    
    static func createMomentWithImage(_ image: UIImage, andDescription description: String, forUser user: User, completion: @escaping (Result<Moment>) -> Void) {
        
//        guard let imageData = UIImageJPEGRepresentation(image, 0.8) else {
//            CLSNSLogv("ERROR: Can't save new MomentImage!", getVaList([]))
//            completion(.failure(LocalizableString.UnableToSaveMoment.localizedString))
//            return
//        }
//        
//        let params: [String : AnyObject] = [UserParameterKey.UserIdKey : user.objectId! as AnyObject]
//        
//        PFCloud.callFunction(inBackground: ParseFunction.GetCountUserMoments.name, withParameters: params) { (result, error) in
//            
//            if let error = error {
//                completion(.failure(error.localizedDescription))
//            } else {
//                if let limit = result as? Int {
//                    if limit < Constants.momentsLimitAmount {
//                        let moment = Moment()
//                        guard let imageFile = PFFile(name: "upload.jpg", data: imageData) else {
//                            completion(.failure("Can't create PFFile with image"))
//                            return
//                        }
//                        
//                        moment.momentUploadImages = imageFile
//                        moment.momentDescription = description
//                        moment.user = user
//                        moment.numberOfLikes = 0
//                        moment.readStatus = true
//                        moment.saveInBackground(block: { (success, error) in
//                            
//                            if success {
//                                CLSNSLogv("Successfully saved new Moment %@", getVaList([moment.objectId!]))
//                                completion(.success(moment))
//                                if user.superUser {
//                                    let params: [String : AnyObject] = [UserParameterKey.UserIdKey : user.objectId! as AnyObject, MomentsKey.MomentId: moment.objectId! as AnyObject]
//                                    PFCloud.callFunction(inBackground: ParseFunction.SuperUserMoment.name, withParameters: params) { (result, error) in
//                                    }
//                                }
//                            } else {
//                                CLSNSLogv("ERROR: Could not save new moment: %@", getVaList([error! as CVarArg]))
//                                completion(.failure(LocalizableString.UnableToSaveMoment.localizedString))
//                            }
//                        })
//                    } else {
//                        completion(.failure(LocalizableString.MomentsLimit.localizedString))
//                    }
//                } else {
//                    completion(.failure(LocalizableString.UnableToSaveMoment.localizedString))
//                }
//            }
//        }
    }
}

//MARK: - Private Methods
extension MomentsProvider {

    fileprivate static func getAllMoments(paginator: PaginationHelper, userId: String, completion: @escaping MomentsCompletion) {
        
//        let params: [String : AnyObject] = [UserParameterKey.UserIdKey : userId as AnyObject,
//                                            MomentsKey.SkipKey : paginator.totalElements as AnyObject,
//                                            MomentsKey.SizeKey : paginator.elementsPerPage as AnyObject]
//        
//        PFCloud.callFunction(inBackground: ParseFunction.GetEverybodyMoments.name, withParameters: params) { (objects, error) in
//            
//            if let error = error {
//                
//                completion(.failure(error.localizedDescription))
//                
//            } else if let moments = objects as? [Moment] {
//                
//                for moment in moments {
//                    
//                    MomentsProvider.userDidLikeMoment(moment, userId: userId, completion: { (result) in
//                        
//                        switch result {
//                            
//                        case .success(let liked):
//                            
//                            moment.likedByCurrentUser = liked
//                            break
//                        case .failure(_):
//                            break
//                        }
//                    })
//                }
//                
//                let delayTime = DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
//                DispatchQueue.main.asyncAfter(deadline: delayTime) {
//                    completion(.success(moments))
//                }
//            }
//        }
    }
    
    fileprivate static func getAllMomentsWithQuery(paginator: PaginationHelper, userId: String, completion: @escaping MomentsCompletion) {
        
//        let query = Moment.query(paginator)
//        query.findObjectsInBackground { (objects, error) in
//            if let error = error {
//                
//                completion(.failure(error.localizedDescription))
//                
//            } else if let moments = objects as? [Moment] {
//                
//                for moment in moments {
//                    
//                    MomentsProvider.userDidLikeMoment(moment, userId: userId, completion: { (result) in
//                        
//                        switch result {
//                            
//                        case .success(let liked):
//                            
//                            moment.likedByCurrentUser = liked
//                            break
//                        case .failure(_):
//                            break
//                        }
//                    })
//                }
//                
//                let delayTime = DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
//                DispatchQueue.main.asyncAfter(deadline: delayTime) {
//                    completion(.success(moments))
//                }
//            }
//        }
    }
    
    fileprivate static func getMyMatchesMoments(paginator: PaginationHelper, userId: String, completion: @escaping MomentsCompletion) {
        
//        let params: [String : AnyObject] = [UserParameterKey.UserIdKey : userId as AnyObject,
//                                            MomentsKey.SkipKey : paginator.totalElements as AnyObject,
//                                            MomentsKey.SizeKey : paginator.elementsPerPage as AnyObject]
//        
//        PFCloud.callFunction(inBackground: ParseFunction.GetMatchesMoments.name, withParameters: params) { (objects, error) in
//            
//            if let error = error {
//                
//                completion(.failure(error.localizedDescription))
//                
//            } else if let moments = objects as? [Moment] {
//                
//                for moment in moments {
//                    
//                    MomentsProvider.userDidLikeMoment(moment, userId: userId, completion: { (result) in
//                        
//                        switch result {
//                            
//                        case .success(let liked):
//                            
//                            moment.likedByCurrentUser = liked
//                            break
//                        case .failure(_):
//                            break
//                        }
//                    })
//                }
//                let delayTime = DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
//                DispatchQueue.main.asyncAfter(deadline: delayTime) {
//                    completion(.success(moments))
//                }
//            }
//        }
    }
    
    fileprivate static func getMyMatchesMomentsNewest(paginator: PaginationHelper, userId: String, completion: @escaping MomentsCompletion) {
        
//        let query = Moment.query(paginator)
//        query.whereKey("user", matchesQuery: User.matchQuery(userId))
//        query.findObjectsInBackground { (objects, error) in
//            if let error = error {
//                
//                completion(.failure(error.localizedDescription))
//                
//            } else if let moments = objects as? [Moment] {
//                
//                for moment in moments {
//                    
//                    MomentsProvider.userDidLikeMoment(moment, userId: userId, completion: { (result) in
//                        
//                        switch result {
//                            
//                        case .success(let liked):
//                            
//                            moment.likedByCurrentUser = liked
//                            break
//                        case .failure(_):
//                            break
//                        }
//                    })
//                }
//                
//                let delayTime = DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
//                DispatchQueue.main.asyncAfter(deadline: delayTime) {
//                    completion(.success(moments))
//                }
//            }
//        }
    }
    
    fileprivate static func getMyMoments(paginator: PaginationHelper, userId: String, completion: @escaping MomentsCompletion) {
        
//        let query = Moment.queryMost(paginator)
//        query.whereKey("user", matchesQuery: User.myQuery(userId))
//        query.findObjectsInBackground { (objects, error) in
//            if let error = error {
//                
//                completion(.failure(error.localizedDescription))
//                
//            } else if let moments = objects as? [Moment] {
//                
//                for moment in moments {
//                    
//                    MomentsProvider.userDidLikeMoment(moment, userId: userId, completion: { (result) in
//                        
//                        switch result {
//                            
//                        case .success(let liked):
//                            
//                            moment.likedByCurrentUser = liked
//                            break
//                        case .failure(_):
//                            break
//                        }
//                    })
//                }
//                
//                let delayTime = DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
//                DispatchQueue.main.asyncAfter(deadline: delayTime) {
//                    completion(.success(moments))
//                }
//            }
//        }

    }
    
  
    
    fileprivate static func getMyMomentsNewest(paginator: PaginationHelper, userId: String, completion: @escaping MomentsCompletion) {
        
//        let query = Moment.query(paginator)
//        query.whereKey("user", matchesQuery: User.myQuery(userId))
//        query.findObjectsInBackground { (objects, error) in
//            if let error = error {
//                
//                completion(.failure(error.localizedDescription))
//                
//            } else if let moments = objects as? [Moment] {
//                
//                for moment in moments {
//                    
//                    MomentsProvider.userDidLikeMoment(moment, userId: userId, completion: { (result) in
//                        
//                        switch result {
//                            
//                        case .success(let liked):
//                            
//                            moment.likedByCurrentUser = liked
//                            break
//                        case .failure(_):
//                            break
//                        }
//                    })
//                }
//                
//                let delayTime = DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
//                DispatchQueue.main.asyncAfter(deadline: delayTime) {
//                    completion(.success(moments))
//                }
//            }
//        }
    }
}
