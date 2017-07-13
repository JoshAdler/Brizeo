//
//  AboutPassionsTableViewCell.swift
//  Brizeo
//
//  Created by Roman Bayik on 7/13/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import ChameleonFramework

class AboutPassionsTableViewCell: UITableViewCell {

    // MARK: - Properties
    
    @IBOutlet var buttons: [UIButton]! {
        didSet {
            
            for button in buttons {
                button.layer.borderWidth = 1.0
                button.layer.borderColor = HexColor("2f98d3")!.cgColor
            }
        }
    }
    
    // MARK: - Override methods
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let buttons = buttons {
            
            for button in buttons {
                button.layer.cornerRadius = button.frame.height / 2.0
            }
        }
    }
    
    // MARK: - Public methods
    
    func setPassions(_ passions: [Passion]) {
        
        for i in 0 ..< buttons.count {
            buttons[i].setTitle(passions[i].displayName, for: .normal)
        }
    }
}
