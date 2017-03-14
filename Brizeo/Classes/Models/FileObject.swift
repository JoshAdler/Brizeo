//
//  FileObject.swift
//  Brizeo
//
//  Created by Roman Bayik on 3/3/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit

class FileObject: NSObject {

    // MARK: - Types
    
    enum FileObjectType: String {
        case image
        case video
    }
    
    enum JSONKeys: String {
        case imgData = "imgData"
        case type = "type"
        case videoUrl = "videoUrl"
        case thumbImage = "thumbImage"
    }
    
    // MARK: - Properties
    
    var sortingIndex: Int = 0
    var type: FileObjectType = .image
    var imageFile: FileObjectInfo?
    var thumbFile: FileObjectInfo?
    var videoFile: FileObjectInfo?
    
    var isImage: Bool {
        return imageFile != nil
    }
    
    var imageUrl: URL? {
        
        if let url = thumbFile?.url { // thumbnail url
            return URL(string: url)
        }
        
        if let url = imageFile?.url { // image url
            return URL(string: url)
        }
        
        return  nil
    }
    
    var mainUrl: String? {
        
        if let url = videoFile?.url { // video url
            return url
        }
        
        if let url = imageFile?.url { // image url
            return url
        }
        
        return  nil
    }
    
    // MARK: - Init methods
    
    init(with JSON: [String: Any]) {
        type = FileObjectType(rawValue: JSON[JSONKeys.type.rawValue] as! String)!
        
        if type == .image {
            let imageDict = JSON[JSONKeys.imgData.rawValue] as! [String: String]
            imageFile = FileObjectInfo(with: imageDict)
        } else {
            let videoDict = JSON[JSONKeys.videoUrl.rawValue] as! [String: String]
            let thumbImageDict = JSON[JSONKeys.thumbImage.rawValue] as! [String: String]
            
            videoFile = FileObjectInfo(with: videoDict)
            thumbFile = FileObjectInfo(with: thumbImageDict)
        }
    }
    
    init(info: FileObjectInfo) {
        imageFile = info
    }
    
    init(thumbnailImage: FileObjectInfo, videoInfo: FileObjectInfo) {
        thumbFile = thumbnailImage
        videoFile = videoInfo
        type = .video
    }
}
