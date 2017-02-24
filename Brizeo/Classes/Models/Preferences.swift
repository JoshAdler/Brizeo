//
//  MatchPreferences.swift
//  Travelx
//
//  Created by Steve Malsam on 1/30/16.
//  Copyright © 2016 Steve Malsam. All rights reserved.
//

import Foundation
import Parse

class Preferences: PFObject, PFSubclassing {
    
    // MARK: - Properties
    
    @NSManaged var ageLowerLimit: Int
    @NSManaged var ageUpperLimit: Int
    @NSManaged var searchLocation: PFGeoPoint
    @NSManaged var searchDistance: CLLocationDistance
    @NSManaged var genders: [String]
    
    // MARK: - Static methods
    
    static func parseClassName() -> String {
        return "Preferences"
    }
    
    // MARK: - Class methods
    // TODO: why static func, not class func?
    class func createPreferences(lowerAgeRange: Int, upperAgeRange: Int, searchLocation: CLLocation, searchDistance: CLLocationDistance, lookingFor: [String]) -> Preferences {
    
        let preferences = Preferences()
        preferences.ageLowerLimit = lowerAgeRange
        preferences.ageUpperLimit = upperAgeRange
        preferences.searchLocation = PFGeoPoint(location: searchLocation)
        preferences.searchDistance = searchDistance
        preferences.genders = lookingFor
        
        return preferences
    }
    
    class func parseGeoPointLocationWithLocation(_ location: CLLocation) -> PFGeoPoint {
        return PFGeoPoint(location: location)
    }
    
    // MARK: - Public methods
    
    func searchLocationCoordinate() -> CLLocation {
        
        return CLLocation(latitude: searchLocation.latitude, longitude: searchLocation.longitude)
    }
}
