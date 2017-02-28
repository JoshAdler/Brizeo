//
//  OtherPersonAboutInvitedByTableViewCell.swift
//  Brizeo
//
//  Created by Roman Bayik on 2/28/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit

protocol InvitedByCellDelegate: class {
    func onInvitedByCellClicked(cell: OtherPersonAboutInvitedByTableViewCell)
}

class OtherPersonAboutInvitedByTableViewCell: UITableViewCell {

    // MARK: - Properties
    
    @IBOutlet weak var invitedByButton: UIButton!
    @IBOutlet weak var invitedByLabel: UILabel! {
        didSet {
            invitedByLabel.text = LocalizableString.InvitedByText.localizedString
        }
    }
    
    weak var delegate: InvitedByCellDelegate?
    
    var invitedByName: String? {
        get {
            return invitedByButton.title(for: .normal)
        }
        set {
            invitedByButton.setTitle(newValue, for: .normal)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func onInvitedByButtonClicked(sender: UIButton) {
        delegate?.onInvitedByCellClicked(cell: self)
    }
}
