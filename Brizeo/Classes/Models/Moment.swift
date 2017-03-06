//
//  Moment.swift
//  Brizeo
//
//  Created by Giovanny Orozco on 5/5/16.
//  Copyright © 2016 Kogi Mobile. All rights reserved.
//

import Foundation
import ObjectMapper

class Moment: Mappable, Equatable {
    
    public static func ==(lhs: Moment, rhs: Moment) -> Bool {
        return lhs.objectId == rhs.objectId
    }

    // MARK: - Types
    
    enum JSONKeys: String {
        case objectId = "objectId"
        case likedByCurrentUser = "likedByCurrentUser"
        case momentDescription = "momentDescription"
        case momentUploadImages = "momentUploadImages"
        case momentsUploadImage = "momentsUploadImage"
        case numberOfLikes = "numberOfLikes"
        case readStatus = "readStatus"
        case user = "user"
        case userId = "userId"
        case viewableByApp = "viewableByApp"
        case passionId = "passionId"
        case latitude = "latitude"
        case longitude = "longitude"
    }
    
    // MARK: - Properties
    
    var objectId: String!
    var isLikedByCurrentUser: Bool = false
    var capture: String = ""
    var likesCount: Int = 0
    var readStatus: Bool = false
    var viewableByApp: Bool = true
    var passionId: String?
    var ownerId: String!
    var locationLongitude: Double?
    var locationLatitude: Double?
    var file: FileObjectInfo!
    var uploadImageUrl: String!
    
    var hasLocation: Bool {
        if locationLongitude != nil && locationLatitude != nil {
            return true
        }
        return false
    }
    
    var imageUrl: URL? {
        return URL(string: uploadImageUrl)
//        guard let url = file.url else { return nil }
//        
//        return URL(string: url)
    }
    
    // MARK: - Init methods
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        
        // ids
        objectId <- map[JSONKeys.objectId.rawValue]
        passionId <- map[JSONKeys.passionId.rawValue]
        ownerId <- map[JSONKeys.userId.rawValue]
        
//        if let userId = JSON[JSONKeys.userId.rawValue] as? String { // new data
//            ownerId = userId
//        } else { // old migrated data
//            if let userDict = JSON[JSONKeys.user.rawValue] as? [String: String] {
//                ownerId = userDict[JSONKeys.objectId.rawValue]! as String
//            }
//        }
        
        // likes information
        isLikedByCurrentUser <- map[JSONKeys.likedByCurrentUser.rawValue]
        likesCount <- map[JSONKeys.numberOfLikes.rawValue]
        
        // availability information
        readStatus <- map[JSONKeys.readStatus.rawValue]
        viewableByApp <- map[JSONKeys.viewableByApp.rawValue]
        
        // basic information
        capture <- map[JSONKeys.momentDescription.rawValue]
        
        // location
        locationLongitude <- map[JSONKeys.longitude.rawValue]
        locationLatitude <- map[JSONKeys.latitude.rawValue]
        
        // file
//        if let fileDict = JSON[JSONKeys.momentUploadImages.rawValue] as? [String: String] {
//            file = FileObjectInfo(with: fileDict)
//        }
        
        // uploaded image url
        uploadImageUrl <- map[JSONKeys.momentsUploadImage.rawValue]
    }
    
    init(with JSON: [String: Any]) {
        
        // ids
        objectId = JSON[JSONKeys.objectId.rawValue] as! String
        passionId = JSON[JSONKeys.passionId.rawValue] as? String
        
        if let userId = JSON[JSONKeys.userId.rawValue] as? String { // new data
            ownerId = userId
        } else { // old migrated data
            if let userDict = JSON[JSONKeys.user.rawValue] as? [String: String] {
                ownerId = userDict[JSONKeys.objectId.rawValue]! as String
            }
        }
        
        // likes information
        isLikedByCurrentUser = JSON[JSONKeys.likedByCurrentUser.rawValue] as! Bool
        likesCount = JSON[JSONKeys.numberOfLikes.rawValue] as! Int
        
        // availability information
        readStatus = JSON[JSONKeys.readStatus.rawValue] as! Bool
        viewableByApp = JSON[JSONKeys.viewableByApp.rawValue] as! Bool
        
        // basic information
        capture = JSON[JSONKeys.momentDescription.rawValue] as! String
        
        // location
        locationLongitude = JSON[JSONKeys.longitude.rawValue] as? Double
        locationLatitude = JSON[JSONKeys.latitude.rawValue] as? Double
        
        // file
        if let fileDict = JSON[JSONKeys.momentUploadImages.rawValue] as? [String: String] {
            file = FileObjectInfo(with: fileDict)
        }
        
        // uploaded image url
        uploadImageUrl = JSON[JSONKeys.momentsUploadImage.rawValue] as? String
    }
    
    // MARK: - Override methods
    
    func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? Moment else { return false }
        
        return object.objectId == objectId
    }
}
