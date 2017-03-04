//
//  Moment.swift
//  Brizeo
//
//  Created by Giovanny Orozco on 5/5/16.
//  Copyright © 2016 Kogi Mobile. All rights reserved.
//

import Foundation

class Moment: NSObject {

    // MARK: - Types
    
    enum JSONKeys: String {
        case objectId = "objectId"
        case likedByCurrentUser = "likedByCurrentUser"
        case momentDescription = "momentDescription"
        case momentUploadImages = "momentUploadImages"
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
    
    var objectId: String
    var isLikedByCurrentUser: Bool = false
    var capture: String = ""
    var likesCount: Int = 0
    var readStatus: Bool
    var viewableByApp: Bool
    var passionId: String?
    var ownerId: String!
    var locationLongitude: Double?
    var locationLatitude: Double?
    var file: FileObjectInfo!
    
    var hasLocation: Bool {
        if locationLongitude != nil && locationLatitude != nil {
            return true
        }
        return false
    }
    
    var imageUrl: URL? {
        guard let url = file.url else { return nil }
        
        return URL(string: url)
    }
    
    // MARK: - Init methods
    
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
    }
    
    // MARK: - Override methods
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? Moment else { return false }
        
        return object.objectId == objectId
    }
}
