//
//  Interest.swift
//  Brizeo
//
//  Created by Arturo on 4/22/16.
//  Copyright © 2016 Kogi Mobile. All rights reserved.
//

import Foundation
import Parse

class Interest : PFObject, PFSubclassing {
    
    // MARK: - Types
    
    struct Constants {
        static let colorPalette = [
            "337bff",
            "fd4444",
            "7d44fd",
            "44ca3a",
            "cbc94c",
            "f975e5",
            "f7b61a",
            "483f47",
        ]
        
        static let icons = [
            #imageLiteral(resourceName: "ic_interests_travel"),
            #imageLiteral(resourceName: "ic_interests_fitness"),
            #imageLiteral(resourceName: "ic_interests_mindfulness"),
            #imageLiteral(resourceName: "ic_interests_foodie"),
            #imageLiteral(resourceName: "ic_interests_arts"),
            #imageLiteral(resourceName: "ic_interests_fashion"),
            #imageLiteral(resourceName: "ic_interests_sports"),
            #imageLiteral(resourceName: "ic_interests_nightlife")
        ]
    }
    
    // MARK: - Properties
    
    @NSManaged var Id: Int
    @NSManaged var DisplayName: String
    @NSManaged var displayOrder: Int
    
    var colorHex: String {
        return Constants.colorPalette[Id]
    }
    
    var imageIcon: UIImage? {
        return Constants.icons[Id]
    }
    
    // MARK: - Static methods
    
    static func parseClassName() -> String {
        return "Interest"
    }
}
