//
//  Interest.swift
//  Brizeo
//
//  Created by Arturo on 4/22/16.
//  Copyright © 2016 Kogi Mobile. All rights reserved.
//

import Foundation

class Passion : NSObject {
    
    // MARK: - Types
    
    enum JSONKeys: String {
        case objectId = "objectId"
        case displayName = "displayName"
        case displayOrder = "displayOrder"
    }
    
    // MARK: - Types
    
    struct Constants {
        static let colorPalette = [
            "0": "337bff",
            "1": "fd4444",
            "2": "7d44fd",
            "3": "44ca3a",
            "4": "cbc94c",
            "5": "f975e5",
            "6": "f7b61a",
            "7": "ffffff", // fashion color
            "8": "483f47"
        ]
        //TODO: ask Josh about color for fashion
        // TODO: ask Charlie about id for each passion
        static let icons = [
            "0": #imageLiteral(resourceName: "ic_interests_travel"),
            "1": #imageLiteral(resourceName: "ic_interests_fitness"),
            "2": #imageLiteral(resourceName: "ic_interests_mindfulness"),
            "3": #imageLiteral(resourceName: "ic_interests_foodie"),
            "4": #imageLiteral(resourceName: "ic_interests_arts"),
            "5": #imageLiteral(resourceName: "ic_interests_fashion"),
            "6": #imageLiteral(resourceName: "ic_interests_sports"),
            "7": #imageLiteral(resourceName: "ic_interests_fashion"),
            "8": #imageLiteral(resourceName: "ic_interests_nightlife")
        ]
    }
    
    // MARK: - Properties
    
    var objectId: String
    var displayName: String
    var displayOrder: Int?
    
    var colorHex: String {
        return Constants.colorPalette[objectId] ?? "ffffff"
    }
    
    var imageIcon: UIImage? {
        return Constants.icons[objectId]
    }
    
    //TODO: remove it later
    class func test() -> Passion {
        let passion = Passion(with: ["objectId": "Some", "displayName": "Some", "displayOrder": 1])
        return passion
    }
    
    // MARK: - Init 
    
    init(with JSON: [String: Any]) {
        objectId = JSON[JSONKeys.objectId.rawValue] as! String
        displayName = JSON[JSONKeys.displayName.rawValue] as! String
        displayOrder = JSON[JSONKeys.displayOrder.rawValue] as? Int ?? 0
        //TODO: check this place
    }
}
