//
//  APILayer.swift
//  Brizeo
//
//  Created by Roman Bayik on 3/5/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import Foundation
import Moya

enum APIService {
    
    // user
    case getCurrentUser(facebookId: String)
    case createNewUser(newUser: User)
    case updateUser(user: User)
    case getUserWithStatus(searchedUserId: String, searchingUserId: String)
    case reportUser(reporterId: String, reportedId: String)
    
    // preferences
    case getPreferences(userId: String)
    case updatePreferences(userId: String, preferences: Preferences)
    
    // moment
    case getMoments(userId: String, sortingFlag: MomentsSortingFlag, filterFlag: String)
    case getAllMoments(sortingFlag: MomentsSortingFlag, filterFlag: String)
    case getMatchedMoments(userId: String, sortingFlag: MomentsSortingFlag, filterFlag: String)
    case createNewMoment(moment: Moment)
    case getLikersForMoment(moment: Moment, userId: String)
    case reportMoment(moment: Moment, reporterId: String)
    case likeMoment(moment: Moment, userId: String)
    case unlikeMoment(moment: Moment, userId: String)
    case deleteMoment(moment: Moment, userId: String)
    case getMoment(momentId: String)
    
    // matching
    case approveMatch(approverId: String, userId: String)
    case declineMatch(approverId: String, userId: String)
    case getUsersForMatch(userId: String)
    case getMatchesForUser(userId: String)
    
    // country
    case addCountryForUser(country: Country, userId: String)
    case deleteCountryForUser(country: Country, userId: String)
    
    // passions
    case getAllPassions
    
    // notifications
    case getNotifications(userId: String)
    
    // info
    case notifyAdminAboutDownloads(userId: String, count: Int)
}

extension APIService: TargetType {
    var baseURL: URL { return URL(string: Configurations.General.apiURL)! }
    
    var path: String {
        switch self {
        case .getCurrentUser(let facebookId):
            return "/users/\(facebookId)"
        case .createNewUser(_):
            return "/users"
        case .updateUser(let user):
            return "/users/\(user.objectId)"
        case .getUserWithStatus(let searchedUserId, let searchingUserId):
            return "/match/\(searchedUserId)/\(searchingUserId)"
        case .reportUser(let reporterId, let reportedId):
            return "/reportuser/\(reporterId)/\(reportedId)"
        case .getPreferences(let userId), .updatePreferences(let userId, _):
            return "/preferences/\(userId)"
        case .addCountryForUser(_, let userId), .deleteCountryForUser(_, let userId):
            return "/countries/\(userId)"
        case .getMoments(let userId, let sortingFlag, let filterFlag):
            return "/moments/\(userId)/\(sortingFlag.rawValue)/\(filterFlag)"
        case .getAllMoments(let sortingFlag, let filterFlag):
            return "/moments/\(sortingFlag.rawValue)/\(filterFlag)"
        case .likeMoment(let moment, let userId), .unlikeMoment(let moment, let userId):
            return "/likemoments/\(userId)/\(moment.objectId)"
        case .getMatchedMoments(let userId, let sortingFlag, let filterFlag):
            return "/matchedmoments/\(userId)/\(sortingFlag.rawValue)/\(filterFlag)"
        case .createNewMoment(_):
            return "/moments"
        case .getMoment(let momentId):
            return "/moments/\(momentId)"
        case .getLikersForMoment(let moment, let userId):
            return "/likemoments/users/\(moment.objectId)/\(userId)"
        case .reportMoment(let moment, let reporterId):
            return "/reportmoment/\(moment.objectId)/\(reporterId)"
        case .deleteMoment(let moment, let userId):
            return "/moments/\(userId)/\(moment.objectId)"
        case .getAllPassions:
            return "/passions"
        case .getNotifications(let userId):
            return "/notifications/\(userId)"
        case .notifyAdminAboutDownloads(let userId, let count):
            return "/downloadevent/\(userId)/\(count)"
        case .approveMatch(let approverId, let userId), .declineMatch(let approverId, let userId):
            return "/match/\(approverId)/\(userId)"
        case .getUsersForMatch(let userId):
            return "/approveuserformatch/\(userId)"
        case .getMatchesForUser(let userId):
            return "/approvematchforuser/\(userId)"
        }
    }

    var method: Moya.Method {
        switch self {
        case .createNewUser(_), .reportMoment(_, _), .reportUser(_, _), .notifyAdminAboutDownloads(_, _), .approveMatch(_, _):
            return .post
        case .updatePreferences(_, _), .updateUser(_), .addCountryForUser(_, _), .createNewMoment(_), .likeMoment(_, _):
            return .put
        case .deleteCountryForUser(_, _), .unlikeMoment(_, _), .deleteMoment(_, _), .declineMatch(_, _):
            return .delete
        default:
            return .get
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .createNewUser(let user):
            let dict = ["newuser": user.toJSON()]
            return dict
        case .updatePreferences(_, let preferences):
            let dict = ["newpref": preferences.toJSON()]
            return dict
        case .updateUser(let user):
            let dict = ["newuser": user.toJSON()]
            return dict
        case .addCountryForUser(let country, _):
            let dict = ["country": country.code]
            return dict
        case .deleteCountryForUser(let country, _):
            let dict = ["country": country.code]
            return dict
        case .createNewMoment(let moment):
            let dict = ["newmoment": moment.toJSON()]
            return dict
        default:
            return nil
        }
    }
    
    var parameterEncoding: ParameterEncoding {
        switch self {
        case .createNewUser(_), .updatePreferences(_, _), .updateUser(_), .addCountryForUser(_, _), .deleteCountryForUser(_, _), .createNewMoment(_):
            return JSONEncoding.default
        default:
            return URLEncoding.default
        }
    }
    
    var multipartBody: [MultipartFormData]? {
        
        switch self {
        case .createNewMoment(let moment):
            
            guard let image = moment.image, let imageData = UIImagePNGRepresentation(image) else {
                return []
            }
            
            let formData: [MultipartFormData] = [MultipartFormData(provider: .data(imageData), name: "uploadFile", fileName: "uploadFile.jpg", mimeType: "image/jpeg")]
            return formData
        default:
            return nil
        }
    }
    
    var sampleData: Data {
        return "No test data".utf8Encoded
    }
    var task: Task {
        switch self {
        case .createNewMoment:
            return .upload(UploadType.multipart(multipartBody!))
            default:
            return .request
        }
    }
}
