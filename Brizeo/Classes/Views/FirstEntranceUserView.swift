//
//  FirstEntranceMomentView.swift
//  Brizeo
//
//  Created by Roman Bayik on 3/12/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit

protocol FirstEntranceUserViewDelegate: class {
    func userView(view: FirstEntranceUserView, didClickedOnArrowUp button: UIButton)
}

class FirstEntranceUserView: UIView {

    // MARK: - Properties
    
    @IBOutlet fileprivate weak var arrowUpButton: UIButton!
    @IBOutlet fileprivate weak var arrowUpButtonBottomConstraint: NSLayoutConstraint!
    weak var delegate: FirstEntranceUserViewDelegate?
    
    var bottomDistance: CGFloat {
        set {
            arrowUpButtonBottomConstraint.constant = newValue
        }
        get {
            return arrowUpButtonBottomConstraint.constant
        }
    }
    
    // MARK: - Actions
    
    @IBAction func onArrowUpButtonClicked(sender: UIButton) {
        delegate?.userView(view: self, didClickedOnArrowUp: sender)
    }
}
