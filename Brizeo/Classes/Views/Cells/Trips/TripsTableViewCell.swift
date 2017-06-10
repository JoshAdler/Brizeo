//
//  TripsTableViewCell.swift
//  Brizeo
//
//  Created by Arturo on 5/13/16.
//  Copyright © 2016 Kogi Mobile. All rights reserved.
//

import UIKit
import SWTableViewCell

class TripsTableViewCell: SWTableViewCell {

    //MARK: - Properties
    
    @IBOutlet weak var countryImageView: UIImageView!
    @IBOutlet weak var countryNameLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    var isChecked: Bool {
        set {
            iconImageView.isHidden = !newValue
        }
        get {
            return !iconImageView.isHidden
        }
    }
    
    // MARK: - Override methods
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if countryImageView != nil {
            countryImageView.layer.cornerRadius = countryImageView.frame.height / 2.0
        }
    }
}
