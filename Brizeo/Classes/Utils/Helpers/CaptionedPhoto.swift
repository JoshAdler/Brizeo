//
//  CaptionedPhoto.swift
//  Travelx
//
//  Created by Sunyan Lee on 2/12/16.
//  Copyright © 2016 Steve Malsam. All rights reserved.
//

import UIKit
import NYTPhotoViewer

class CaptionedPhoto: NSObject, NYTPhoto {
    
    var image: UIImage?
    var placeholderImage: UIImage? = BrizeoImage.ChatImagePlaceholder.image
    var imageData : Data?
    let attributedCaptionTitle: NSAttributedString?
    let attributedCaptionSummary: NSAttributedString? = NSAttributedString(string: "", attributes: [NSForegroundColorAttributeName: UIColor.gray])
    let attributedCaptionCredit: NSAttributedString? = NSAttributedString(string: "", attributes: [NSForegroundColorAttributeName: UIColor.darkGray])
    
    init(imageData: Data, captionTitle: String) {
        self.imageData = imageData
        self.attributedCaptionTitle = NSAttributedString(string: captionTitle, attributes: [NSForegroundColorAttributeName: UIColor.gray])
        super.init()
    }
}
