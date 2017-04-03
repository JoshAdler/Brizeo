//
//  OptionsInputTableViewCell.swift
//  Brizeo
//
//  Created by Roman Bayik on 4/3/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit

class OptionsInputTableViewCell: UITableViewCell {

    // MARK: - Properties
    
    @IBOutlet weak var textField: UITextField!
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
