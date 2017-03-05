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
        
        let provider = MoyaProvider<APIService>()
        provider.request(.getPreferences(userId: userId)) { (result) in
            switch result {
            case .success(let response):
                
//                shared.currentUserPreferences = responce
                completion?(.success(shared.currentUserPreferences!))
                break
            case .failure(let error):
                completion?(.failure(error.localizedDescription))
                break
            }
        }
    }
    
    class func updatePreferences(with userId: String, preferences: Preferences, completion: @escaping (Result<Preferences>) -> Void) {
        
        let provider = MoyaProvider<APIService>()
        provider.request(.updatePreferences(userId: userId, preferences: preferences)) { (result) in
            switch result {
            case .success(let response):
                //                shared.currentUserPreferences = preferences
                completion(.success(preferences))
                break
            case .failure(let error):
                completion(.failure(error.localizedDescription))
                break
            }
        }
    }
}
