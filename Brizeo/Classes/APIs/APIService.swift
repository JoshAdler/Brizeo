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
    case getUserWithStatus(currentUserId: String, searchedUserId: String)
    case reportUser(reporterId: String, reportedId: String)
    case updateUserFile(file: FileObject?, userId: String, type: String, oldURL: String?)
    
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
    case updateMoment(moment: Moment)
    
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
    case updateNotification(notification: Notification)
    
    // info
    case notifyAdminAboutDownloads(userId: String, count: Int)
    
    // events
    case saveEvents(events: [Event])
    case getEvents(sortFlag: String, longitude: Double?, latitude: Double?)
    case getMatchedEvents(userId: String, sortFlag: String, longitude: Double?, latitude: Double?)
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
        case .updateUserFile(_, let userId, let type, _):
            return "upload/\(userId)/\(type)"
        case .getUserWithStatus(let currentUserId, let searchedUserId):
            return "/match/\(currentUserId)/\(searchedUserId)"
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
        case .updateMoment(let moment):
            return "/moments/\(moment.objectId)"
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
        case .updateNotification(let notification):
            return "/notifications/\(notification.objectId)"
        case .saveEvents(_):
            return "/events/"
        case .getEvents(let sortingFlag, _, _):
            return "/allevents/\(sortingFlag)"
        case .getMatchedEvents(let userId, let sortingFlag, _, _):
            return "/events/\(userId)/\(sortingFlag)"
        }
    }

    var method: Moya.Method {
        switch self {
        case .createNewUser(_), .reportMoment(_, _), .reportUser(_, _), .notifyAdminAboutDownloads(_, _), .approveMatch(_, _), .updateUserFile(_, _, _, _), .saveEvents(_):
            return .post
        case .updatePreferences(_, _), .updateUser(_), .addCountryForUser(_, _), .createNewMoment(_), .likeMoment(_, _), .updateMoment(_), .updateNotification(_), .getEvents(_, _, _):
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
        case .createNewMoment(let moment), .updateMoment(let moment):
            let dict = ["newmoment": moment.toJSON()]
            return dict
        case .updateUserFile(_, _, _, let oldURL):
            if let oldURL = oldURL {
                return ["oldurl": oldURL]
            }
            return nil
        case .updateNotification(let notification):
            let dict = ["newnotification": notification.toJSON()]
            return dict
        case .saveEvents(let events):
            var eventsDict = [[String: Any]]()
            
            for event in events {
                eventsDict.append(event.toJSON())
            }
            
            let finalDict = ["newevents": eventsDict]
            return finalDict
        case .getEvents(_, let longitude, let latitude):
            if let longitude = longitude, let latitude = latitude {
                
                let dict = [
                    "lat": latitude,
                    "lon": longitude
                ]
                
                return dict
            }
            return nil
        default:
            return nil
        }
    }
    
    var parameterEncoding: ParameterEncoding {
        switch self {
        case .createNewUser(_), .updatePreferences(_, _), .updateUser(_), .addCountryForUser(_, _), .deleteCountryForUser(_, _), .createNewMoment(_), .updateMoment(_), .updateNotification(_), .saveEvents(_), .getEvents(_, _, _), .getMatchedEvents(_, _, _, _):
            return JSONEncoding.default
        default:
            return URLEncoding.default
        }
    }
    
    var multipartBody: [MultipartFormData]? {
        
        switch self {
        case .createNewMoment(let moment):
            
            var formDataArray = [MultipartFormData]()
            
            if let image = moment.image, let imageData = UIImagePNGRepresentation(image) {
                let formData = MultipartFormData(provider: .data(imageData), name: "uploadFile", fileName: "uploadFile.jpg", mimeType: "image/jpeg")
                formDataArray.append(formData)
            }
            
            if let videoURL = moment.videoURL {
                let formData = MultipartFormData(provider: .file(videoURL), name: "uploadFile", fileName: "uploadFile.mov", mimeType: "video/quicktime")
                formDataArray.append(formData)
            }
            
            if let thumbnail = moment.thumbnailImage, let thumbnailData = UIImagePNGRepresentation(thumbnail) {
                let formData = MultipartFormData(provider: .data(thumbnailData), name: "thumbnailImage", fileName: "thumbnailImage.jpg", mimeType: "image/png")
                formDataArray.append(formData)
            }

            return formDataArray
        case .updateUserFile(let file, _, _, _):
            var formDataArray = [MultipartFormData]()
            
            if let image = file?.imageFile?.image, let imageData = UIImagePNGRepresentation(image) {
                let formData = MultipartFormData(provider: .data(imageData), name: "uploadFile", fileName: "uploadFile.jpg", mimeType: "image/jpeg")
                formDataArray.append(formData)
            }
            
            if let videoURL = file?.videoFile?.url {
                let formData = MultipartFormData(provider: .file(URL(string: videoURL)!), name: "uploadFile", fileName: "uploadFile.mov", mimeType: "video/quicktime")
                formDataArray.append(formData)
            }
            
            if let thumbnail = file?.thumbFile?.image, let thumbnailData = UIImagePNGRepresentation(thumbnail) {
                let formData = MultipartFormData(provider: .data(thumbnailData), name: "thumbnailImage", fileName: "thumbnailImage.jpg", mimeType: "image/png")
                formDataArray.append(formData)
            }
            
            return formDataArray
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
        case .updateUserFile(let file, _, _, _):
            if file == nil {
                return .request
            } else {
                return .upload(UploadType.multipart(multipartBody!))
            }
            default:
            return .request
        }
    }
}
