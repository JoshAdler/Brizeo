//
//  PreferencesProvider.swift
//  Brizeo
//
//  Created by Giovanny Orozco on 5/3/16.
//  Copyright © 2016 Kogi Mobile. All rights reserved.
//

import Foundation
import Parse

struct PreferencesProvider {

    static func getUserMatchPrefs(_ user: User, result:@escaping ((Result<Preferences>) -> Void)) {
        
        let pfQuery = PFQuery(className: "Preferences")
        pfQuery.whereKey("user", equalTo: user)
        pfQuery.findObjectsInBackground { (objects, error) in
            
            if let error = error {
                
                result(.failure(error.localizedDescription))
                
            } else if let preferences = objects?.first as? Preferences {
                
                result(.success(preferences))
            }
        }
    }
    
    static func saveParseUserPrefs(_ preferences: Preferences, user: User, completion: @escaping (Result<Void>) -> Void) {
        
        let searchLocation = preferences.searchLocation
        let searchCoordString = "\(searchLocation.latitude),\(searchLocation.longitude)"
        let interestsArray = user.interests
        let interestString = interestsArray.joined(separator: ",")
        let gendersString = preferences.genders.joined(separator: ",")
        
        let params:[String: AnyObject] = ["userId":user.objectId! as AnyObject,
                                          "interests": interestString as AnyObject,
                                          "ageUpperLimit": preferences.ageUpperLimit as AnyObject,
                                          "ageLowerLimit": preferences.ageLowerLimit as AnyObject,
                                          "searchDistance": preferences.searchDistance as AnyObject,
                                          "searchLocation": searchCoordString as AnyObject,
                                          "genders": gendersString as AnyObject]
        
        PFCloud.callFunction(inBackground: "setMatchPreferences", withParameters: params, block: { (result, error) in
            if(error != nil) {
                completion(.failure(error!.localizedDescription))
                return
            }
            
            completion(.success())
        })
    }
}
