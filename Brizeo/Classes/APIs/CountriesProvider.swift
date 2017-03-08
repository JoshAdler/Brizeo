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
    
    class func addCountry(countries: [Country], for userId: String, completion: @escaping (Result<[Country]>) -> Void) {
        
        let provider = MoyaProvider<APIService>()
        provider.request(.addCountriesForUser(countries: countries, userId: userId)) { (result) in
            switch result {
            case .success(let response):
                
                guard response.statusCode == 200 else {
                    completion(.failure(APIError(code: response.statusCode, message: nil)))
                    return
                }
                
                UserProvider.shared.currentUser!.countries = UserProvider.shared.currentUser!.countries.filter({ !countries.map({ $0.code }).contains($0.code) })
                
                completion(.success(countries))
                break
            case .failure(let error):
                completion(.failure(APIError(error: error)))
                break
            }
        }
    }
    
    class func deleteCountry(countries: [Country], for userId: String, completion: @escaping (Result<[Country]>) -> Void) {
        
        let provider = MoyaProvider<APIService>()
        provider.request(.deleteCountriesForUser(countries: countries, userId: userId)) { (result) in
            switch result {
            case .success(let response):
                
                guard response.statusCode == 200 else {
                    completion(.failure(APIError(code: response.statusCode, message: nil)))
                    return
                }

                UserProvider.shared.currentUser!.countries = UserProvider.shared.currentUser!.countries.filter({ !countries.map({ $0.code }).contains($0.code) })
                
                completion(.success(countries))
                break
            case .failure(let error):
                completion(.failure(APIError(error: error)))
                break
            }
        }
    }
}
