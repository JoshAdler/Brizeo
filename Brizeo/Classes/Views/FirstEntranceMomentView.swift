//
//  FirstEntranceMomentView.swift
//  Brizeo
//
//  Created by Roman Bayik on 3/12/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit

protocol FirstEntranceMomentViewDelegate: class {
    func momentView(view: FirstEntranceMomentView, didClickedOnCreate button: UIButton)
    func momentView(view: FirstEntranceMomentView, didClickedOnHide button: UIButton)
}

class FirstEntranceMomentView: UIView {

    // MARK: - Properties
    
    @IBOutlet fileprivate weak var createButton: UIButton!
    @IBOutlet fileprivate weak var createButtonRightConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var createButtonTopConstraint: NSLayoutConstraint!
    weak var delegate: FirstEntranceMomentViewDelegate?
    
    var topDistance: CGFloat {
        set {
            createButtonTopConstraint.constant = newValue
        }
        get {
            return createButtonTopConstraint.constant
        }
    }
    
    var rightDistance: CGFloat {
        set {
            createButtonRightConstraint.constant = newValue
        }
        get {
            return createButtonRightConstraint.constant
        }
    }
    
    // MARK: - Actions
    
    @IBAction func onCreateButtonClicked(sender: UIButton) {
        delegate?.momentView(view: self, didClickedOnCreate: sender)
    }
    
    @IBAction func onHideButtonClicked(sender: UIButton) {
        delegate?.momentView(view: self, didClickedOnHide: sender)
    }
}
