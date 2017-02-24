//
//  SettingsCheckmarkCell.swift
//  Brizeo
//
//  Created by Roman Bayik on 1/28/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit

class SettingsCheckmarkCell: UITableViewCell {

    // MARK: - Properties
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    var isChecked: Bool {
        set {
            iconImageView.isHidden = !newValue
        }
        get {
            return !iconImageView.isHidden
        }
    }
}
