//
//  MapTransforms.swift
//  Brizeo
//
//  Created by Roman Bayik on 3/6/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import Foundation
import Moya_ObjectMapper
import ObjectMapper

class LastActiveDateTransform: TransformType {
    public typealias Object = Date
    public typealias JSON = String
    
    public init() {}
    
    open func transformFromJSON(_ value: Any?) -> Date? {
        if let timeStr = value as? String {
            return Helper.convertStringToDate(string: timeStr)
        }
        
        return nil
    }
    
    open func transformToJSON(_ value: Date?) -> String? {
        if let date = value {
            return date.toLongString
        }
        
        return nil
    }
}

class CountriesTransform: TransformType {
    public typealias Object = Array<Country>
    public typealias JSON = Array<String>
    
    public init() {}
    
    open func transformFromJSON(_ value: Any?) -> Array<Country>? {
        var countries = [Country]()
        
        if let array = value as? [String] {
            for code in array {
                countries.append(Country.initWith(code))
            }
        }
        
        return countries
    }
    
    open func transformToJSON(_ value: Array<Country>?) -> Array<String>? {
        if let value = value {
            if value.count == 0 {
                return nil
            }
            
            var JSONArray = [String]()
            for country in value {
                JSONArray.append(country.code)
            }
            
            return JSONArray
        } else {
            return nil
        }
    }
}
