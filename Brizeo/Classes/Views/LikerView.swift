//
//  LikerView.swift
//  Brizeo
//
//  Created by Roman Bayik on 2/6/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit

class LikerView: UIView {

    // MARK: - Properties
    
    @IBOutlet weak var diclineButton: UIButton!
    @IBOutlet weak var approveButton: UIButton!
    @IBOutlet weak var matchedLabel: UILabel!
    
    var isMatched: Bool {
        get {
            return !matchedLabel.isHidden
        }
        set {
            diclineButton.isHidden = newValue
            approveButton.isHidden = newValue
            matchedLabel.isHidden = !newValue
        }
    }
}
