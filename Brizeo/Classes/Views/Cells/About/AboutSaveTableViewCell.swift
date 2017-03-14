//
//  AboutSaveTableViewCell.swift
//  Brizeo
//
//  Created by Roman Bayik on 3/14/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit

protocol AboutSaveTableViewCellDelegate: class {
    
    func aboutSaveCell(cell: AboutSaveTableViewCell, didClickedOnSave button: UIButton)
}

class AboutSaveTableViewCell: UITableViewCell {

    // MARK: - Properties
    
    @IBOutlet weak var saveButton: UIButton! {
        didSet {
            saveButton.setTitle(LocalizableString.Save.localizedString, for: .normal)
            saveButton.layer.cornerRadius = 7.0
        }
    }
    weak var delegate: AboutSaveTableViewCellDelegate?
    
    // MARK: - Actions
    
    @IBAction func onSaveButtonClicked(sender: UIButton) {
        delegate?.aboutSaveCell(cell: self, didClickedOnSave: sender)
    }
}
