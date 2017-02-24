//
//  AboutTableViewCell.swift
//  Brizeo
//
//  Created by Roman Bayik on 1/30/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit

protocol AboutTableViewCellDelegate: class {
    func aboutTableViewCell(_ cell: AboutTableViewCell, onSelectViewClicked index: Int)
}

class AboutTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var firstSelectView: AboutSelectView! {
        didSet {
            firstSelectView.delegate = self
        }
    }
    @IBOutlet weak var secondSelectView: AboutSelectView! {
        didSet {
            secondSelectView.delegate = self
        }
    }
    @IBOutlet weak var thirdSelectView: AboutSelectView! {
        didSet {
            thirdSelectView.delegate = self
        }
    }
    weak var delegate: AboutTableViewCellDelegate?
    
    var selectedIndex: Int {
        get {
            return firstSelectView.isSelected ? 0 : (secondSelectView.isSelected ? 1 : 2)
        }
        set {
            firstSelectView.isSelected = firstSelectView == selectView(with: newValue)
            secondSelectView.isSelected = secondSelectView == selectView(with: newValue)
            thirdSelectView.isSelected = thirdSelectView == selectView(with: newValue)
        }
    }
    
    // MARK: - Private methods
    
    fileprivate func selectView(with index: Int) -> AboutSelectView? {
        switch index {
        case 0:
            return firstSelectView
        case 1:
            return secondSelectView
        case 2:
            return thirdSelectView
        default:
            return nil
        }
    }
}

// MARK: - AboutSelectViewDelegate
extension AboutTableViewCell: AboutSelectViewDelegate {
    
    func aboutSelectedViewDidClicked(view: AboutSelectView) {
        delegate?.aboutTableViewCell(self, onSelectViewClicked: view.tag)
    }
}
