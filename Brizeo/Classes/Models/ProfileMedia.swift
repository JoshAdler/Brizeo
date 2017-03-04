//
//  ProfileMediaEnum.swift
//  Travelx
//
//  Created by Steve Malsam on 1/24/16.
//  Copyright © 2016 Steve Malsam. All rights reserved.
//

//import Foundation
//import Parse
//
//enum ProfileMediaType {
//    
//    case image(imageFile: PFFile, description: String?)
//    case video(videoFile: PFFile, thumbImage: PFFile, description: String?)
//    case empty
//}
//
//func ImageDataToProfileMediaType(_ imageData: Data) -> ProfileMediaType? {
//    guard let imageFile = PFFile(name: "profile.jpg", data: imageData) else {
//        assertionFailure("Can't create profile media type")
//        return nil
//    }
//    
//    DispatchQueue.global(qos: .default).async {
//        () -> Void in
//        do {
//            try imageFile.save()
//        } catch {
//        }
//    }
//    
//    return PFFileToProfileMediaType(["type": "image" as AnyObject, "imgdata": imageFile])
//}
//
//func VideoDataToProfileMediaType(_ videoData: Data, thumbImageData: Data) -> ProfileMediaType? {
//    guard let videoFile = PFFile(name: "video.mp4", data: videoData) else {
//        assertionFailure("Can't create video data to profile media type")
//        return nil
//    }
//    
//   DispatchQueue.global(qos: .default).async {
//        () -> Void in
//        do {
//            try videoFile.save()
//        } catch {
//        }
//    }
//    
//    guard let imageFile = PFFile(data: thumbImageData) else {
//        assertionFailure("Can't create thumbImage to profile media type")
//        return nil
//    }
//    
//    DispatchQueue.global(qos: .default).async {
//        () -> Void in
//        do {
//            try imageFile.save()
//        } catch {
//        }
//    }
//    
//    return PFFileToProfileMediaType(["type": "video" as AnyObject, "videoUrl": videoFile, "thumbImage": imageFile])
//}
//
//func ProfileMediaTypePreviewUrl(_ file: ProfileMediaType) -> String? {
//    
//    var userImage: PFFile? = nil
//    switch(file) {
//    case .video(_, let thumbImage, _):
//        
//        userImage = thumbImage
//        break
//    case .image(let imageFile, _):
//        
//        userImage = imageFile
//        break
//    
//    default:
//        break
//    }
//    
//    if let image = userImage {
//        
//        return image.url
//    }
//    
//    return nil
//}
//
//func ProfileMediaTypeDescription(_ file: ProfileMediaType) -> String? {
//    switch file {
//    case .image(_, let description):
//        return description
//    case .video(_, _, let description):
//        return description
//    case .empty:
//        return nil
//    }
//}
//
//func PFFileToProfileMediaType(_ mediaInfo: [String : AnyObject]) -> ProfileMediaType {
//    var newType: ProfileMediaType = .empty
//    guard let type = mediaInfo["type"] as? String else {
//        return newType
//    }
//    
//    if(type == "image") {
//        newType = .image(imageFile:mediaInfo["imgdata"] as! PFFile, description: nil)
//    } else if (type == "video") {
//        newType = .video(videoFile: mediaInfo["videoUrl"] as! PFFile, thumbImage: mediaInfo["thumbImage"] as! PFFile, description: nil)
//    }
//    
//    return newType
//}
//
//func ProfileMediaTypeToPFFile(_ mediaInfo: ProfileMediaType) -> [String : AnyObject] {
//    switch(mediaInfo) {
//    case .image(let imageFile, _):
//        return ["type":"image" as AnyObject, "imgdata": imageFile]
//        
//    case .video(let videoFile, let thumbImage, _):
//        return ["type":"video" as AnyObject, "videoUrl":videoFile, "thumbImage":thumbImage]
//        
//    case .empty:
//        return [:]
//    }
//}
