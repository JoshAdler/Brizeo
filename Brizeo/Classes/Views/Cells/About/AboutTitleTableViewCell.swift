//
//  AboutTitleTableViewCell.swift
//  Brizeo
//
//  Created by Roman Bayik on 3/14/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit

class AboutTitleTableViewCell: UITableViewCell {

    // MARK: - Properties
    
    @IBOutlet weak var firstLabel: UILabel! /* label for first passion */ {
        didSet {
            firstLabel.text = LocalizableString.First.localizedString
        }
    }
    @IBOutlet weak var secondLabel: UILabel! /* label for second passion */ {
        didSet {
            secondLabel.text = LocalizableString.Second.localizedString
        }
    }
    @IBOutlet weak var thirdLabel: UILabel! /* label for third passion */ {
        didSet {
            thirdLabel.text = LocalizableString.Third.localizedString
        }
    }
}
