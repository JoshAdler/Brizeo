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
        return
        let moments = isFirstTime ? Array(moments.prefix(Constants.momentsLimitAmount)) : moments
        print("We need to cache moment count : \(moments.count)")
        
        let momentsUrls = moments.filter({ $0.imageUrl != nil }).map({ $0.imageUrl })
        let usersUrls = moments.map({ $0.user.profileUrl }).filter({ $0 != nil })
        
        SDWebImagePrefetcher.shared().prefetchURLs(momentsUrls)
        SDWebImagePrefetcher.shared().prefetchURLs(usersUrls)
    }
    
    class func getMoments(for userId: String, sortingFlag: MomentsSortingFlag, filterFlag: String?, completion: @escaping MomentsCompletion) {
        
        APIService.performRequest(request: .getMoments(userId: userId, sortingFlag: sortingFlag, filterFlag: filterFlag ?? "all")) { (result) in
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
    
    class func updateMoment(moment: Moment, completion: MomentCompletion?) {
        
        moment.updatedAt = Date()
        
        APIService.performRequest(request: .updateMoment(moment: moment)) { (result) in
            switch result {
            case .success(let response):
                
                guard response.statusCode == 200 else {
                    completion?(.failure(APIError(code: response.statusCode, message: nil)))
                    return
                }
                
                completion?(.success(moment))
                print("successfully updated moment")
                
                break
            case .failure(let error):
                completion?(.failure(APIError(error: error)))
                break
            }
        }
    }
    
    class func getAllMoments(sortingFlag: MomentsSortingFlag, filterFlag: String?,currentPageIndex: Int, completion: @escaping MomentsCompletion) {
        
        APIService.performRequest(request: .getAllMoments(sortingFlag: sortingFlag, filterFlag: filterFlag ?? "all", pageIndex: currentPageIndex)) { (result) in
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
        
        APIService.performRequest(request: .getMoment(momentId: momentId)) { (result) in
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
        
        APIService.performRequest(request: .getMatchedMoments(userId: userId, sortingFlag: sortingFlag, filterFlag: filterFlag ?? "all")) { (result) in
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
        
        APIService.performRequest(request: .createNewMoment(moment: moment)) { (result) in
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
        
        APIService.performRequest(request: .deleteMoment(moment: moment, userId: user.objectId)) { (result) in
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
        
        APIService.performRequest(request: .getLikersForMoment(moment: moment, userId: user.objectId)) { (result) in
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
        
        APIService.performRequest(request: .reportMoment(moment: moment, reporterId: user.objectId)) { (result) in
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
        
        APIService.performRequest(request: .likeMoment(moment: momentToLike, userId: user.objectId)) { (result) in
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
        
        APIService.performRequest(request: .unlikeMoment(moment: momentToUnlike, userId: user.objectId)) { (result) in
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
            getAllMoments(sortingFlag: sortingFlag, filterFlag: filterPassion?.objectId, currentPageIndex: paginator.currentPage, completion: completion)
        case .myMatches(let userId):
            getMatchedMoments(userId: userId, sortingFlag: sortingFlag, filterFlag: filterPassion?.objectId, completion: completion)
        case .myMoments(let userId):
            getMoments(for: userId, sortingFlag: sortingFlag, filterFlag: filterPassion?.objectId, completion: completion)
        }
    }
}

