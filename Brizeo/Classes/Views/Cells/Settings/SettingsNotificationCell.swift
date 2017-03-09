//
//  NotificationTableViewCell.swift
//  Brizeo
//
//  Created by Monkey on 9/6/16.
//  Copyright © 2016 Kogi Mobile. All rights reserved.
//

import UIKit

protocol SettingsNotificationCellDelegate: class {
    func notificationCell(cell: SettingsNotificationCell, didChangedValueTo value: Bool)
}

class SettingsNotificationCell: UITableViewCell {

    // MARK: - Properties
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var switcher: UISwitch! {
        didSet {
            switcher.transform = CGAffineTransform(scaleX: 0.816, y: 0.69)
        }
    }
    
    weak var delegate: SettingsNotificationCellDelegate?
    
    // MARK: - Actions
    
    @IBAction func didSwitcherValueChanged(switcher: UISwitch) {
        delegate?.notificationCell(cell: self, didChangedValueTo: switcher.isOn)
    }
}
// TODO: update user about switcher change
