//
//  Event.swift
//  Brizeo
//
//  Created by Roman Bayik on 3/20/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import ObjectMapper
import CoreLocation

class Event: NSObject, Mappable {

    // MARK: - Types
    
    enum JSONKeys: String {
        case objectId = "objectId"
        case name = "name"
        case information = "information"
        case latitude = "latitude"
        case longitude = "longitude"
        case previewImageLink = "previewImageLink"
        case attendingsCount = "attendingsCount"
        case startDate = "startDate"
        case ownerUser = "user"
        case ownerId = "ownerUser"
        case distance = "distance"
    }
    
    // MARK: - Properties
    
    var objectId: String = "-1"
    var facebookId: String = "-1"
    var ownerId: String = "-1"
    var name: String = "No name"
    var information: String = "No information"
    var latitude: Double?
    var longitude: Double?
    var previewImageLink: String?
    var attendingsCount: Int = 0
    var startDate: Date?
    var ownerUser: User!
    var distance: Double?
    
    var previewImageUrl: URL? {
        guard previewImageLink != nil else {
            return nil
        }
        
        return URL(string: previewImageLink!)
    }
    
    var startDateString: String? {
        guard let startDate = startDate else {
            return nil
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a, d MMM yyyy"
        
        return formatter.string(from: startDate)
    }
    
    var hasLocation: Bool {
        if longitude != nil && latitude != nil {
            return true
        }
        return false
    }
    
    var location: CLLocation? {
        get {
            guard hasLocation else {
                return nil
            }
            
            return CLLocation(latitude: latitude!, longitude: longitude!)
        }
        set {
            latitude = newValue?.coordinate.latitude
            longitude = newValue?.coordinate.longitude
        }
    }
    
    // MARK: - Init
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {

        objectId <- map[JSONKeys.objectId.rawValue]
        name <- map[JSONKeys.name.rawValue]
        information <- map[JSONKeys.information.rawValue]
        latitude <- map[JSONKeys.latitude.rawValue]
        longitude <- map[JSONKeys.longitude.rawValue]
        previewImageLink <- map[JSONKeys.previewImageLink.rawValue]
        attendingsCount <- map[JSONKeys.attendingsCount.rawValue]
        startDate <- (map[JSONKeys.startDate.rawValue], FacebookDateTransform())
        ownerUser <- map[JSONKeys.ownerUser.rawValue]
        ownerId <- map[JSONKeys.ownerId.rawValue]
        distance <- map[JSONKeys.distance.rawValue]
    }
    
    init(facebookId: String, name: String?, information: String?, latitude: Double?, longitude: Double?, imageLink: String?, attendingsCount: Int?, startDate: Date?) {
        
        self.facebookId = facebookId
        self.name = name ?? "No name"
        self.information = information ?? "No description"
        self.latitude = latitude
        self.longitude = longitude
        self.previewImageLink = imageLink
        self.attendingsCount = attendingsCount ?? 0
        self.startDate = startDate
        
        ownerId = UserProvider.shared.currentUser?.objectId ?? "-1"
    }
}
