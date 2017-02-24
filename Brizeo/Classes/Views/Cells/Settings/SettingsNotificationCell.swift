//
//  NotificationTableViewCell.swift
//  Brizeo
//
//  Created by Monkey on 9/6/16.
//  Copyright © 2016 Kogi Mobile. All rights reserved.
//

import UIKit

class SettingsNotificationCell: UITableViewCell {

    // MARK: - Properties
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var switcher: UISwitch! {
        didSet {
            switcher.transform = CGAffineTransform(scaleX: 0.816, y: 0.69)
        }
    }
}
// TODO: update user about switcher change
