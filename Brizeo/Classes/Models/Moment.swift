//
//  Moment.swift
//  Brizeo
//
//  Created by Giovanny Orozco on 5/5/16.
//  Copyright © 2016 Kogi Mobile. All rights reserved.
//

import Foundation
import ObjectMapper
import CoreLocation

class Moment: Mappable, Equatable {
    
    public static func ==(lhs: Moment, rhs: Moment) -> Bool {
        return lhs.objectId == rhs.objectId
    }

    // MARK: - Types
    
    enum JSONKeys: String {
        case objectId = "objectId"
        case likedByCurrentUser = "likedBycurrentUser"
        case momentDescription = "momentDescription"
        case momentsUploadImage = "momentsUploadImage"
        case numberOfLikes = "numberOfLikes"
        case readStatus = "readStatus"
        case user = "user"
        case userId = "userId"
        case viewableByAll = "viewableByAll"
        case passionId = "passionId"
        case latitude = "currentLocation.latitude"
        case longitude = "currentLocation.longitude"
        case uploadFile = "uploadFile"
    }
    
    // MARK: - Properties
    
    var objectId: String = "-1"
    var ownerId: String = "-1"
    var isLikedByCurrentUser: Bool = false
    var capture: String = ""
    var likesCount: Int = 0
    var readStatus: Bool = false
    var viewableByAll: Bool = true
    var passionId: String?
    var locationLongitude: Double?
    var locationLatitude: Double?
    var file: FileObjectInfo!
    var user: User!
    
    //variables for uploading
    var image: UIImage?
    var videoURL: URL?
    var thumbnailImage: UIImage?
    
    var hasLocation: Bool {
        if locationLongitude != nil && locationLatitude != nil {
            return true
        }
        return false
    }
    
    var imageUrl: URL? {
        guard let url = file?.url else { return nil }
        
        return URL(string: url)
    }
    
    var location: CLLocation? {
        get {
            guard hasLocation else {
                return nil
            }
            
            return CLLocation(latitude: locationLatitude!, longitude: locationLongitude!)
        }
        set {
            locationLatitude = newValue?.coordinate.latitude
            locationLongitude = newValue?.coordinate.longitude
        }
    }
    
    // MARK: - Init methods
    
    init() {}
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        
        // ids
        objectId <- map[JSONKeys.objectId.rawValue]
        passionId <- map[JSONKeys.passionId.rawValue]
        ownerId <- map[JSONKeys.userId.rawValue]
        user <- map[JSONKeys.user.rawValue]
        
        // likes information
        isLikedByCurrentUser <- (map[JSONKeys.likedByCurrentUser.rawValue], LikersTransform())
        likesCount <- map[JSONKeys.numberOfLikes.rawValue]
        
        // availability information
        readStatus <- map[JSONKeys.readStatus.rawValue]
        viewableByAll <- map[JSONKeys.viewableByAll.rawValue]
        
        // basic information
        capture <- map[JSONKeys.momentDescription.rawValue]
        
        // location
        locationLongitude <- (map[JSONKeys.longitude.rawValue], LocationTransform())
        locationLatitude <- (map[JSONKeys.latitude.rawValue], LocationTransform())
        
        // uploaded image url
        file <- (map[JSONKeys.momentsUploadImage.rawValue], FileObjectInfoTransform())
    }
    
    // MARK: - Override methods
    
    func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? Moment else { return false }
        
        return object.objectId == objectId
    }
}
