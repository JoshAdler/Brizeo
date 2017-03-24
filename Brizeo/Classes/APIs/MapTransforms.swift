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
            return date.toFacebookString
        }
        
        return nil
    }
}

class FacebookDateTransform: TransformType {
    public typealias Object = Date
    public typealias JSON = String
    
    public init() {}
    
    open func transformFromJSON(_ value: Any?) -> Date? {
        if let timeStr = value as? String {
            return Helper.convertFacebookStringToDate(string: timeStr)
        }
        
        return nil
    }
    
    open func transformToJSON(_ value: Date?) -> String? {
        if let date = value {
            return date.toFacebookString
        }
        
        return nil
    }
}

class ThumbnailImagesTransform: TransformType {
    
    public typealias Object = [String: String]
    public typealias JSON = [String: String]
    
    public init() {}
    
    public func transformFromJSON(_ value: Any?) -> [String: String]? {
        
        if let result = value as? [String: String] {
            return result
        }
        
        if let result = value as? [String] {
            
            var dict = [String: String]()
            
            for i in 0..<result.count {
                dict["\(i)"] = result[i] 
            }
            
            return dict
        }
        
        return nil
    }
    
    public func transformToJSON(_ value: Dictionary<String, String>?) -> Dictionary<String, String>? {
        
        return value
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

class FileObjectInfoTransform: TransformType {
    public typealias Object = FileObjectInfo
    public typealias JSON = String
    
    public init() {}
    
    public func transformFromJSON(_ value: Any?) -> FileObjectInfo? {
        
        if let url = value as? String {
            let file = FileObjectInfo(urlStr: url)
            return file
        }
        
        return nil
    }
    
    open func transformToJSON(_ value: FileObjectInfo?) -> String? {
        
        if let value = value {
            return value.url
        }
        
        return nil
    }
}

class FileObjectTransform: TransformType {
    public typealias Object = FileObject
    public typealias JSON = String
    
    public init() {}
    
    public func transformFromJSON(_ value: Any?) -> FileObject? {
        
        if let url = value as? String {
            let file = FileObject(info: FileObjectInfo(urlStr: url))
            return file
        }
        
        return nil
    }
    
    open func transformToJSON(_ value: FileObject?) -> String? {
        
        if let value = value {
            return value.mainUrl
        }
        
        return nil
    }
}

class LikersTransform: TransformType {

    public typealias Object = Bool
    public typealias JSON = Array<String>
    
    public init() {}
    
    
    public func transformFromJSON(_ value: Any?) -> Bool? {
     
        guard let currentUser = UserProvider.shared.currentUser else {
            return nil
        }
        
        if let value = value as? [String] {
            return value.contains(currentUser.objectId)
        }
            
        return nil
    }
    
    public func transformToJSON(_ value: Bool?) -> Array<String>? {
        return nil
    }
}

class MomentRawDataTransform: TransformType {
    
    public typealias Object = Data
    public typealias JSON = String
    
    public init() {}
    
    
    public func transformFromJSON(_ value: Any?) -> Data? {
        if let value = value as? String {
            let data = Data(base64Encoded: value)
            return data
        }
        
        return nil
    }
    
    public func transformToJSON(_ value: Data?) -> String? {
        if let value = value {
            return value.base64EncodedString()
        }
        
        return nil
    }
}

class LocationTransform: TransformType {
    
    public typealias Object = Double
    public typealias JSON = Double
    
    public init() {}
    
    public func transformFromJSON(_ value: Any?) -> Double? {
        
        if let doubleValue = value as? Double {
            return doubleValue
        }
        
        if let strValue = value as? String, let doubleValue = Double(strValue) {
            return doubleValue
        }
        
        return nil
    }
    
    public func transformToJSON(_ value: Double?) -> Double? {
        
        if value != nil {
            return value
        }
        
        return nil
    }
}
