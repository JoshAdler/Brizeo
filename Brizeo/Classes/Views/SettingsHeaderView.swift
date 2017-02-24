//
//  SettingsHeaderView.swift
//  Brizeo
//
//  Created by Roman Bayik on 1/31/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import ChameleonFramework

class SettingsHeaderView: UITableViewHeaderFooterView {
    
    // MARK: - Properties

    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: - Override methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.backgroundColor = HexColor("EBEBEB")
    }
}
