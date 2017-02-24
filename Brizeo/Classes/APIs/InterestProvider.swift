//
//  InterestProvider.swift
//  Brizeo
//
//  Created by Giovanny Orozco on 5/3/16.
//  Copyright © 2016 Kogi Mobile. All rights reserved.
//

import Foundation
import Parse

struct InterestProvider {
    
    static func retrieveAllInterests(_ result:@escaping ((Result<[Interest]>) -> Void)) {
        
        let pfQuery = PFQuery(className: "Interest")
        pfQuery.findObjectsInBackground { (objects, error) in
            
            if let error = error {
                
                result(.failure(error.localizedDescription))
                
            } else if let interests = objects as? [Interest] {
                
                result(.success(interests))
            }
        }
    }
}
