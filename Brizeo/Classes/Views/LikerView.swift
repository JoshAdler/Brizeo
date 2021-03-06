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
    
    var isDeclined: Bool {
        get {
            return diclineButton.isHidden && approveButton.isHidden && matchedLabel.isHidden
        }
        set {
            diclineButton.isHidden = newValue
            approveButton.isHidden = newValue
            matchedLabel.isHidden = newValue
        }
    }
    
    var isActionHidden: Bool {
        get {
            return diclineButton.isHidden && approveButton.isHidden
        }
        set {
            diclineButton.isHidden = newValue
            approveButton.isHidden = newValue
        }
    }
    
    // MARK: - Public methods
    
    func hideEverything() {
        matchedLabel.isHidden = true
        isActionHidden = true
    }
    
    func operateStatus(status: MatchingStatus) {
        switch status {
        case .isMatched:
            isActionHidden = true
            matchedLabel.isHidden = true
        case .isRejectedByCurrentUser, .didRejectEachOther, .didApproveButCurrentReject, .didRejectCurrentUser, .didRejectButCurrentApprove, .isApprovedByCurrentUser:
            isActionHidden = true
            matchedLabel.isHidden = true
        default:
            isActionHidden = false
            matchedLabel.isHidden = true
        }
    }
}
