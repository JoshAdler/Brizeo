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

enum PassionType {
    case normal
    case extended
}

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
    var extendedPassions: [Passion]? {
        
        didSet {
            if extendedPassions != nil {
                extendedPassions!.sort(by: { (leftObj, rightObj) -> Bool in
                    return leftObj.displayName < rightObj.displayName
                })
            }
        }
    }
    
    // MARK: - Public methods
    
    func retrieveAllPassions(_ fromCache: Bool, type: PassionType, _ completion: ((Result<[Passion]>) -> Void)?) {
        
        let passionArray = type == .normal ? passions : extendedPassions
        let isCacheUsed = fromCache && passionArray != nil
        
        if isCacheUsed {
            completion?(.success(passionArray!))
        }
        
        if isCacheUsed {
            getAllPassions(for: type, completion: nil)
        } else {
            getAllPassions(for: type) { (result) in
                completion?(result)
            }
        }
    }
    
    /* RB Comment: Unused method
    func getPassion(with objectId: String,_ withUsingCache: Bool, completion: @escaping (Result<Passion>) -> Void) {
        
        // get passion from cache
        if passions != nil && withUsingCache {
            if let passion = passions?.filter({ $0.objectId == objectId }).first {
                completion(.success(passion))
                return
            }
        }
        
        // load passions from web api
        getAllPassions(for: ) { (result) in
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
 */
    
    func getAllPassions(for type: PassionType, completion: ((Result<[Passion]>) -> Void)?) {
        var request: APIService
        
        switch type {
        case .normal:
            request = .getAllPassions
        case .extended:
            request = .getAllExtendedPassions
        }
        
        APIService.performRequest(request: request) { (result) in
            switch result {
            case .success(let response):
                
                guard response.statusCode == 200 else {
                    completion?(.failure(APIError(code: response.statusCode, message: nil)))
                    return
                }
                
                do {
                    
                    if let passionsDict = Mapper<Passion>().mapDictionary(JSONObject: try response.mapJSON()) {
                        let passions = Array(passionsDict.values)
                        
                        if type == .normal {
                            PassionsProvider.shared.passions = passions
                        } else {
                            PassionsProvider.shared.extendedPassions = passions
                        }
                        
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
    
    func getPassion(by id: String, with type: PassionType) -> Passion? {
        
        guard let passions = (type == .normal ? passions : extendedPassions) else {
            return nil
        }
        
        return passions.filter({ $0.objectId == id }).first
    }
}
