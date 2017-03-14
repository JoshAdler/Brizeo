//
//  AboutInputTableViewCell.swift
//  Brizeo
//
//  Created by Roman Bayik on 3/14/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import KMPlaceholderTextView

class AboutInputTableViewCell: UITableViewCell {

    // MARK: - Properties
    
    @IBOutlet weak var textView: KMPlaceholderTextView! {
        didSet {
            textView.placeholder = LocalizableString.SaySomethingAboutYourself.localizedString
        }
    }
}
