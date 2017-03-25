//
//  FileObjectInfo.swift
//  Brizeo
//
//  Created by Roman Bayik on 3/4/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit

class FileObjectInfo: NSObject {

    // MARK: - Types
    
    enum JSONKeys: String {
        case name = "name"
        case url = "url"
    }
    
    // MARK: - Properties
    
    var image: UIImage?
    var name: String?
    var url: String?
    
    // MARK: - Init 
    
    init(with JSON: [String: Any]) {
        name = JSON[JSONKeys.name.rawValue] as? String
        url = JSON[JSONKeys.url.rawValue] as? String
    }
    
    init?(urlStr: String?) {
        
        guard let urlStr = urlStr else {
            return nil
        }
        
        guard urlStr.numberOfCharactersWithoutSpaces() > 0 else {
            return nil
        }
        
        self.url = urlStr
    }
    
    init(url: URL) {
        self.url = url.absoluteString
    }
    
    init(image: UIImage) {
        self.image = image
    }
}
