//
//  InterestProvider.swift
//  Brizeo
//
//  Created by Giovanny Orozco on 5/3/16.
//  Copyright © 2016 Kogi Mobile. All rights reserved.
//

import Foundation
import ObjectMapper
import Moya
import SDWebImage

struct PassionsProvider {
    
    // MARK: - Properties
    
    static var shared = PassionsProvider()
    var passions: [Passion]? {
        didSet {
            if passions != nil {
                let urls = passions!.filter({ $0.iconURL != nil }).map({ $0.iconURL })
                SDWebImagePrefetcher.shared().prefetchURLs(urls)
            }
        }
    }
    
    // MARK: - Public methods
    //TODO: add reachability and load passions when the internet connection appears
    func retrieveAllPassions(_ fromCache: Bool, _ completion: ((Result<[Passion]>) -> Void)?) {
        
        let isCacheUsed = fromCache && passions != nil
        if isCacheUsed {
            completion?(.success(passions!))
        }
        
        if isCacheUsed {
            getAllPassions(completion: nil)
        } else {
            getAllPassions { (result) in
                completion?(result)
            }
        }
    }
    
    func getPassion(with objectId: String,_ withUsingCache: Bool, completion: @escaping (Result<Passion>) -> Void) {
        
        // get passion from cache
        if passions != nil && withUsingCache {
            if let passion = passions?.filter({ $0.objectId == objectId }).first {
                completion(.success(passion))
                return
            }
        }
        
        // load passions from web api
        getAllPassions { (result) in
            switch(result) {
            case .success(let passions):
                if let passion = passions.filter({ $0.objectId == objectId }).first {
                    completion(.success(passion))
                    return
                } else {
                    completion(.failure(APIError(code: 0, message: "There is no passion wtih such id")))
                }
                break
            case .failure(let error):
                completion(.failure(error))
            default: break
            }
        }
    }
    
    func getAllPassions(completion: ((Result<[Passion]>) -> Void)?) {
        
        let provider = MoyaProvider<APIService>()
        provider.request(.getAllPassions) { (result) in
            switch result {
            case .success(let response):
                guard response.statusCode == 200 else {
                    completion?(.failure(APIError(code: response.statusCode, message: nil)))
                    return
                }
                
                do {
                if let passionsDict = Mapper<Passion>().mapDictionary(JSONObject: try response.mapJSON()) {
                    let passions = Array(passionsDict.values)
                    
                    PassionsProvider.shared.passions = passions
                    completion?(.success(passions))
                    //self.passions = passions.sorted(by: {$0.displayOrder < $1.displayOrder})
                } else {
                    completion?(.failure(APIError(code: 0, message: "Can't parse passion data")))
                    }
                } catch (let error) {
                    completion?(.failure(APIError(error: error)))
                }
                
                break
            case .failure(let error):
                completion?(.failure(APIError(error: error)))
                break
            }
        }
    }
}
