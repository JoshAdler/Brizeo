//
//  Country.swift
//  Brizeo
//
//  Created by Roman Bayik on 1/30/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import ObjectMapper

class Country: Mappable, Equatable {

    static func ==(lhs: Country, rhs: Country) -> Bool {
        return lhs.code == rhs.code
    }

    // MARK: - Properties
    
    var code: String = ""
    var name: String = ""
    var sortingIndex: Int = 0
    
    var flagImage: UIImage? {
        let imagePath = String(format: "CountryPicker.bundle/%@", code.uppercased())
        guard let image = UIImage(named: imagePath) else {
            return nil
        }
        
        return image
    }
    
    // MARK: - Init
    
    required init?(map: Map) { }
    
    init(code: String, name: String) {
        self.code = code
        self.name = name
    }
    
    func mapping(map: Map) {
    }
    
    // MARK: - Class methods
    
    class func initWith(_ code: String) -> Country {
        let locale = Locale(identifier: "en_US")
        return Country(code: code, name: (locale as NSLocale).displayName(forKey: NSLocale.Key.countryCode, value: code)!)
    }
}
