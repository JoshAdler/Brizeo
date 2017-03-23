//
//  EventTableViewCell.swift
//  Brizeo
//
//  Created by Mobile on 12/10/16.
//  Copyright © 2016 Kogi Mobile. All rights reserved.
//

import UIKit

protocol EventTableViewCellDelegate: class {
    
    func eventCell(cell: EventTableViewCell, didClickedOnProfile button: UIButton)
}

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
    @IBOutlet weak var eventOwnerImageView: UIImageView! {
        didSet {
            eventOwnerImageView.layer.borderColor = UIColor.black.cgColor
            eventOwnerImageView.layer.borderWidth = 2.0
        }
    }
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var eventStartDate: UILabel!
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var eventDescription: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var attendingLabel: UILabel!
    weak var delegate: EventTableViewCellDelegate?
    
    // MARK: - Override methods
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if eventOwnerImageView != nil {
            eventOwnerImageView.layer.cornerRadius = eventOwnerImageView.frame.width / 2.0
        }
        
        if profileButton != nil {
            profileButton.layer.cornerRadius = profileButton.frame.width / 2.0
        }
    }
    
    // MARK: - Actions
    
    @IBAction func onProfileButtonClicked(sender: UIButton) {
        delegate?.eventCell(cell: self, didClickedOnProfile: sender)
    }
}
