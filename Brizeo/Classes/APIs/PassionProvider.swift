//
//  InterestProvider.swift
//  Brizeo
//
//  Created by Giovanny Orozco on 5/3/16.
//  Copyright © 2016 Kogi Mobile. All rights reserved.
//

import Foundation
import Parse

struct PassionsProvider {
    
    // MARK: - Properties
    
    static let shared = PassionsProvider()
    var passions: [Passion]?
    
    // MARK: - Public methods
    //TODO: add reachability and load passions when the internet connection appears
    func retrieveAllPassions(_ fromCache: Bool, _ result: ((Result<[Passion]>) -> Void)?) {
        
        if fromCache && passions != nil {
            result?(.success(passions!))
        }
        
        //self.passions = passions.sorted(by: {$0.displayOrder < $1.displayOrder})
        // TODO: make a request and cache result
    }
    
    func getPassion(with objectId: String,_ withUsingCache: Bool, completion: (Result<Passion>) -> Void) {
        
        // get passion from cache
        if passions != nil && withUsingCache {
            if let passion = passions?.filter({ $0.objectId == objectId }).first {
                completion(.success(passion))
                return
            }
        }
        
        // load passion from web api
        completion(.success(Passion.test()))
    }
}
