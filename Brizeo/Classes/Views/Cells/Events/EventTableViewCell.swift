//
//  EventTableViewCell.swift
//  Brizeo
//
//  Created by Mobile on 12/10/16.
//  Copyright © 2016 Kogi Mobile. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    @IBOutlet weak var locationImageView: UIImageView! {
        didSet {
            locationImageView.image = locationImageView.image!.withRenderingMode(.alwaysTemplate)
        }
    }
    @IBOutlet weak var attendingImageView: UIImageView! {
        didSet {
            attendingImageView.image = attendingImageView.image!.withRenderingMode(.alwaysTemplate)
        }
    }
    
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var eventOwnerImageView: UIImageView!
    @IBOutlet weak var eventStartDate: UILabel!
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var eventDescription: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var attendingLabel: UILabel!
    
    // MARK: - Override methods
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        eventOwnerImageView.layer.cornerRadius = eventOwnerImageView.frame.width / 2.0
    }
}
