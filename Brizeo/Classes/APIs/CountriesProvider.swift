//
//  CountriesProvider.swift
//  Brizeo
//
//  Created by Roman Bayik on 3/5/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import Moya

class CountriesProvider: NSObject {

    // MARK: - Class methods
    
    class func addCountry(country: Country, for userId: String, completion: @escaping (Result<User>) -> Void) {
        
        APIService.performRequest(request: .addCountryForUser(country: country, userId: userId)) { (result) in
            switch result {
            case .success(let response):
                
                guard response.statusCode == 200 else {
                    completion(.failure(APIError(code: response.statusCode, message: nil)))
                    return
                }
                
                do {
                    if let countriesArray = try response.mapJSON() as? [String] {
                        var countries = [Country]()
                        
                        for code in countriesArray {
                            countries.append(Country.initWith(code))
                        }
                        UserProvider.shared.currentUser?.countries = countries
                        completion(.success(UserProvider.shared.currentUser!))
                    } else {
                        completion(.failure(APIError(code: 0, message: "Can't parse response.")))
                    }
                } catch (let error) {
                    completion(.failure(APIError(error: error)))
                }
                break
            case .failure(let error):
                completion(.failure(APIError(error: error)))
                break
            }
        }
    }
    
    class func deleteCountry(country: Country, for userId: String, completion: @escaping (Result<User>) -> Void) {
        
        APIService.performRequest(request: .deleteCountryForUser(country: country, userId: userId)) { (result) in
            switch result {
            case .success(let response):
                
                guard response.statusCode == 200 else {
                    completion(.failure(APIError(code: response.statusCode, message: nil)))
                    return
                }
                
                do {
                    if let countriesArray = try response.mapJSON() as? [String] {
                        var countries = [Country]()
                        
                        for code in countriesArray {
                            countries.append(Country.initWith(code))
                        }
                        UserProvider.shared.currentUser?.countries = countries
                        completion(.success(UserProvider.shared.currentUser!))
                    } else {
                        completion(.failure(APIError(code: 0, message: "Can't parse response.")))
                    }
                } catch (let error) {
                    completion(.failure(APIError(error: error)))
                }
                break
            case .failure(let error):
                completion(.failure(APIError(error: error)))
                break
            }
        }
    }
}
