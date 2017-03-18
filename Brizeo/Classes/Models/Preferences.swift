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
import Applozic

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
        case isNotificationsNewMatchesOn = "isNotificationsNewMatchesOn"
        case isNotificationsMessagesOn = "isNotificationsMessagesOn"
        case isNotificationsMomentsLikesOn = "isNotificationsMomentsLikesOn"
    }
    
    // MARK: - Properties
    
    var objectId: String = "0"
    var ageLowerLimit: Int = 0
    var ageUpperLimit: Int = 0
    var genders: [Gender] = []
    var maxSearchDistance: Int = 100
    var longitude: Double?
    var latitude: Double?
    var isNotificationsNewMatchesOn: Bool = true
    var isNotificationsMomentsLikeOn: Bool = true
    var isNotificationsMessagesOn: Bool = true {
        didSet {
            updateApplozicNotificationMode()
        }
    }

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
        isNotificationsNewMatchesOn <- map[JSONKeys.isNotificationsNewMatchesOn.rawValue]
        isNotificationsMessagesOn <- map[JSONKeys.isNotificationsMessagesOn.rawValue]
        isNotificationsMomentsLikeOn <- map[JSONKeys.isNotificationsMomentsLikesOn.rawValue]
    }
    
    // MARK: - Public methods
    
    func updateApplozicNotificationMode() {
        
        let mode: Int16 = isNotificationsMessagesOn ? 0 : 1
        ALRegisterUserClientService.updateNotificationMode(mode) { (response, error) in
            if error == nil {
                ALUserDefaultsHandler.setNotificationMode(mode)
            }
        }
    }
    
    func getNotificationInfo(for index: Int) -> (String, Bool) {
        print("index \(index)")
        switch index {
        case 0:
            return (LocalizableString.NewMatches.localizedString, isNotificationsNewMatchesOn)
        case 1:
            return (LocalizableString.Messages.localizedString, isNotificationsMessagesOn)
        case 2:
            return (LocalizableString.MomentsLikes.localizedString, isNotificationsMomentsLikeOn)
        default:
            return ("", false)
        }
    }
    
    func setNotificationValue(value: Bool, for index: Int) {
        switch index {
        case 0:
            isNotificationsNewMatchesOn = value
        case 1:
            isNotificationsMessagesOn = value
        case 2:
            isNotificationsMomentsLikeOn = value
        default:
            break
        }
    }
}






