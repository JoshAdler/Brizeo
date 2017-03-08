//
//  MatchPreferences.swift
//  Travelx
//
//  Created by Steve Malsam on 1/30/16.
//  Copyright © 2016 Steve Malsam. All rights reserved.
//

import Foundation
import ObjectMapper
import CoreLocation

class Preferences: Mappable {
    
    // MARK: - Types
    
    enum JSONKeys: String {
        case objectId = "objectId"
        case ageLowerLimit = "upperAgeLimit"
        case ageUpperLimit = "lowerAgeLimit"
        case genders = "genders"
        case maxSearchDistance = "maxSearchDistance"
        case searchLocationLatitude = "searchLocation.latitude"
        case searchLocationLongitude = "searchLocation.longitude"
    }
    
    // MARK: - Properties
    //TODO: check whether there is a object id?
    var objectId: String = "0"
    var ageLowerLimit: Int = 0
    var ageUpperLimit: Int = 0
    var genders: [Gender] = []
    var maxSearchDistance: Int = 100
    var longitude: Double?
    var latitude: Double?

    var hasLocation: Bool {
        if longitude != nil && latitude != nil {
            return true
        }
        return false
    }
    
    var searchLocation: CLLocation? {
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
    
    // MARK: - Init methods
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        
        objectId <- map[JSONKeys.objectId.rawValue]
        ageLowerLimit <- map[JSONKeys.ageLowerLimit.rawValue]
        ageUpperLimit <- map[JSONKeys.ageUpperLimit.rawValue]
        genders <- (map[JSONKeys.genders.rawValue], EnumTransform<Gender>())
        maxSearchDistance <- map[JSONKeys.maxSearchDistance.rawValue]
        longitude <- map[JSONKeys.searchLocationLongitude.rawValue]
        latitude <- map[JSONKeys.searchLocationLatitude.rawValue]
    }
}






