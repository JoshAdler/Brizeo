//
//  Interest.swift
//  Brizeo
//
//  Created by Arturo on 4/22/16.
//  Copyright © 2016 Kogi Mobile. All rights reserved.
//

import Foundation
import ObjectMapper
import ChameleonFramework

class Passion : Mappable {
    
    // MARK: - Types
    
    enum JSONKeys: String {
        case objectId = "objectId"
        case displayOrder = "displayOrder"
        case primaryDisplayName = "primaryDisplayName"
        case secondaryDisplayName = "secondaryDisplayName"
        case thirdDisplayName = "thirdDisplayName"
        case colorHex = "colorHex"
        case iconURL = "iconURL"
    }
    
    // MARK: - Properties
    
    var objectId: String!
    var displayOrder: Int?
    var primaryDisplayName: String?
    var secondaryDisplayName: String?
    var thirdDisplayName: String?
    var colorHex: String?
    var iconURL: String?
    
    var color: UIColor {
        let hex = colorHex ?? "ffffff"
        return HexColor(hex)!
    }
    
    var displayName: String {
        if let primaryDisplayName = primaryDisplayName {
            return primaryDisplayName
        }
        
        if let secondaryDisplayName = secondaryDisplayName {
            return secondaryDisplayName
        }
        
        if let thirdDisplayName = thirdDisplayName {
            return thirdDisplayName
        }
        return "Unknown"
    }
    
    // MARK: - Init 
    
    required init?(map: Map) { }
    
    init(with JSON: [String: Any]) {
        objectId = JSON[JSONKeys.objectId.rawValue] as! String
        primaryDisplayName = JSON[JSONKeys.primaryDisplayName.rawValue] as? String
        secondaryDisplayName = JSON[JSONKeys.secondaryDisplayName.rawValue] as? String
        thirdDisplayName = JSON[JSONKeys.thirdDisplayName.rawValue] as? String
        displayOrder = JSON[JSONKeys.displayOrder.rawValue] as? Int ?? 0
    }
    
    func mapping(map: Map) {
        
        objectId <- map[JSONKeys.objectId.rawValue]
        primaryDisplayName <- map[JSONKeys.primaryDisplayName.rawValue]
        secondaryDisplayName <- map[JSONKeys.secondaryDisplayName.rawValue]
        thirdDisplayName <- map[JSONKeys.thirdDisplayName.rawValue]
        displayOrder <- map[JSONKeys.displayOrder.rawValue]
        colorHex <- map[JSONKeys.colorHex.rawValue]
        iconURL <- map[JSONKeys.iconURL.rawValue]
    }
}
