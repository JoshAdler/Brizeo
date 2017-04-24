//
//  PreferencesProvider.swift
//  Brizeo
//
//  Created by Giovanny Orozco on 5/3/16.
//  Copyright © 2016 Kogi Mobile. All rights reserved.
//

import Foundation
import Moya

class PreferencesProvider: NSObject {

    // MARK: - Properties
    
    static let shared = PreferencesProvider()
    
    var currentUserPreferences: Preferences?
    
    // MARK: - Init
    
    private override init() {}
    
    // MARK: - Class methods
    
    class func loadPreferences(for userId: String, fromCache: Bool, completion: ((Result<Preferences>) -> Void)?) {

        if fromCache && shared.currentUserPreferences != nil {
            completion?(.success(shared.currentUserPreferences!))
            
            loadPreferences(for: userId, fromCache: false, completion: nil)
            return
        }
        
        APIService.performRequest(request: .getPreferences(userId: userId)) { (result) in
            switch result {
            case .success(let response):
                
                guard response.statusCode == 200 else {
                    completion?(.failure(APIError(code: response.statusCode, message: nil)))
                    return
                }
                
                do {
                    let preferences = try response.mapObject(Preferences.self)
                    
                    if !preferences.hasLocation {
                        preferences.searchLocation = LocationManager.shared.currentLocationCoordinates
                    }
                    
                    shared.currentUserPreferences = preferences
                    completion?(.success(preferences))
                }
                catch (let error) {
                    completion?(.failure(APIError(error: error)))
                }
                break
            case .failure(let error):
                completion?(.failure(APIError(error: error)))
                break
            }
        }
    }
    
    class func updatePreferences(preferences: Preferences, completion: ((Result<Preferences>) -> Void)?) {
        
        guard let currentUser = UserProvider.shared.currentUser else {
            print("Error: Can't update preferences without current user.")
            completion?(.failure(APIError(code: 0, message: "Can't update preferences without current user.")))
            return
        }
        
        APIService.performRequest(request: .updatePreferences(userId: currentUser.objectId, preferences: preferences)) { (result) in
            switch result {
            case .success(let response):
                guard response.statusCode == 200 else {
                    completion?(.failure(APIError(code: response.statusCode, message: nil)))
                    return
                }

                shared.currentUserPreferences = preferences
                completion?(.success(preferences))
                break
            case .failure(let error):
                completion?(.failure(APIError(error: error)))
                break
            }
        }
    }
}
