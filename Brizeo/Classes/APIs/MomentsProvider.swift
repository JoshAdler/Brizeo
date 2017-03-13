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
        static let momentsLimitAmount = 30
    }
    
    fileprivate struct MomentsKey {
        static let SkipKey = "skip"
        static let SizeKey = "size"
        static let MomentId = "imageId"
    }
    
    // MARK: - Class methods
    
    class func preloadMomentPictures(isFirstTime: Bool, moments: [Moment]) {
        let moments = isFirstTime ? Array(moments.prefix(Constants.momentsLimitAmount)) : moments
        print("We need to cache moment count : \(moments.count)")
        
        let momentsUrls = moments.filter({ $0.imageUrl != nil }).map({ $0.imageUrl })
        let usersUrls = moments.map({ $0.user.profileUrl }).filter({ $0 != nil })
        
        SDWebImagePrefetcher.shared().prefetchURLs(momentsUrls)
        SDWebImagePrefetcher.shared().prefetchURLs(usersUrls)
    }
    
    class func getMoments(for userId: String, sortingFlag: MomentsSortingFlag, filterFlag: String?, completion: @escaping MomentsCompletion) {
        
        let provider = MoyaProvider<APIService>()
        provider.request(.getMoments(userId: userId, sortingFlag: sortingFlag, filterFlag: filterFlag ?? "all")) { (result) in
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
    
    class func getMoment(with momentId: String, completion: @escaping MomentCompletion) {
        
        let provider = MoyaProvider<APIService>()
        provider.request(.getMoment(momentId: momentId)) { (result) in
            switch result {
            case .success(let response):
                
                guard response.statusCode == 200 else {
                    completion(.failure(APIError(code: response.statusCode, message: nil)))
                    return
                }
                
                do {
                    let moments = try response.mapObject(Moment.self)
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
    
    class func create(new moment: Moment, completion: @escaping MomentCompletion) {
        
        let provider = MoyaProvider<APIService>()
        provider.request(.createNewMoment(moment: moment)) { (result) in
            switch result {
            case .success(let response):
                
                guard response.statusCode == 200 else {
                    completion(.failure(APIError(code: response.statusCode, message: nil)))
                    return
                }
                
                do {
                    let newMomentId = try response.mapString()
                    
                    moment.objectId = newMomentId
                    completion(.success(moment))
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
                
                guard response.statusCode == 200 else {
                    completion(.failure(APIError(code: response.statusCode, message: nil)))
                    return
                }
                
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
        
        guard let user = UserProvider.shared.currentUser else {
            print("Error: Can't delete moment without current user")
            completion(.failure(APIError(code: 0, message: "Can't delete moment without current user")))
            return
        }
        
        let provider = MoyaProvider<APIService>()
        provider.request(.getLikersForMoment(moment: moment, userId: user.objectId)) { (result) in
            switch result {
            case .success(let response):
                
                guard response.statusCode == 200 else {
                    completion(.failure(APIError(code: response.statusCode, message: nil)))
                    return
                }
                
                do {
                    let users = try response.mapArray(User.self)
                    completion(.success(users))
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
                guard response.statusCode == 200 else {
                    completion(.failure(APIError(code: response.statusCode, message: nil)))
                    return
                }
                
                completion(.success(moment))
                break
            case .failure(let error):
                completion(.failure(APIError(error: error)))
                break
            }
        }
    }
    
    class func like(momentToLike: Moment, completion: @escaping MomentCompletion) {
        
        guard let user = UserProvider.shared.currentUser else {
            print("Error: Can't like moment without current user")
            completion(.failure(APIError(code: 0, message: "Can't like moment without current user")))
            return
        }
        
        let provider = MoyaProvider<APIService>()
        provider.request(.likeMoment(moment: momentToLike, userId: user.objectId)) { (result) in
            switch result {
            case .success(let response):
                
                guard response.statusCode == 200 else {
                    completion(.failure(APIError(code: response.statusCode, message: nil)))
                    return
                }
                
                do {
                    let moment = try response.mapObject(Moment.self)
                    
                    if moment.objectId == momentToLike.objectId {
                        moment.user = momentToLike.user
                    }
                    
                    completion(.success(moment))
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
    
    class func unlike(momentToUnlike: Moment, completion: @escaping MomentCompletion) {
        
        guard let user = UserProvider.shared.currentUser else {
            print("Error: Can't unlike moment without current user")
            completion(.failure(APIError(code: 0, message: "Can't unlike moment without current user")))
            return
        }
        
        let provider = MoyaProvider<APIService>()
        provider.request(.unlikeMoment(moment: momentToUnlike, userId: user.objectId)) { (result) in
            switch result {
            case .success(let response):
                
                guard response.statusCode == 200 else {
                    completion(.failure(APIError(code: response.statusCode, message: nil)))
                    return
                }
                
                do {
                    let moment = try response.mapObject(Moment.self)
                    
                    if moment.objectId == momentToUnlike.objectId {
                        moment.user = momentToUnlike.user
                    }
                    
                    completion(.success(moment))
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
