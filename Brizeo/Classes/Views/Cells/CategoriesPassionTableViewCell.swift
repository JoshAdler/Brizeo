//
//  CategoriesPassionTableViewCell.swift
//  Brizeo
//
//  Created by Roman Bayik on 7/13/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import ChameleonFramework
import UIKit

protocol CategoriesPassionTableViewCellDelegate: class {
    func categoryCell(cell: CategoriesPassionTableViewCell, didClickedOnLeft button: UIButton)
    func categoryCell(cell: CategoriesPassionTableViewCell, didClickedOnRight button: UIButton)
}

class CategoriesPassionTableViewCell: UITableViewCell {

    // MARK: - Types
    
    struct Constants {
        static let selectedBorderColor = HexColor("2f98d3")
        static let selectedBackgroundColor = HexColor("1f4ba5")
        static let selectedFontColor = UIColor.white
        
        static let defaultBorderColor = HexColor("868686")
        static let defaultBackgroundColor = UIColor.white
        static let defaultFontColor = HexColor("868686")
        
    }
    
    // MARK: - Properties
    
    @IBOutlet weak var leftPassionButton: UIButton! {
        didSet {
            leftPassionButton.layer.borderWidth = 1.0
            leftPassionButton.layer.borderColor = HexColor("2f98d3")!.cgColor
        }
    }
    @IBOutlet weak var rightPassionButton: UIButton! {
        didSet {
            rightPassionButton.layer.borderWidth = 1.0
            rightPassionButton.layer.borderColor = HexColor("2f98d3")!.cgColor
        }
    }
    
    weak var delegate: CategoriesPassionTableViewCellDelegate?
    
    // MARK: - Override methods
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        leftPassionButton.layer.cornerRadius = leftPassionButton.frame.height / 2.0
        rightPassionButton.layer.cornerRadius = rightPassionButton.frame.height / 2.0
    }
    
    // MARK: - Public methods
    
    func setLeftPassion(passion: Passion) {
        leftPassionButton.setTitle(passion.displayName, for: .normal)
    }
    
    func setRightPassion(passion: Passion?) {
        guard passion != nil else {
            
            rightPassionButton.isHidden = true
            return
        }
        
        rightPassionButton.setTitle(passion!.displayName, for: .normal)
        rightPassionButton.isHidden = false
    }
    
    func setIsLeftSelected(_ isSelected: Bool) {
        isSelected ? enableButton(leftPassionButton) : disableButton(leftPassionButton)
    }
    
    func setIsRightSelected(_ isSelected: Bool) {
        isSelected ? enableButton(rightPassionButton) : disableButton(rightPassionButton)
    }
    
    // MARK: - Private methods
    
    fileprivate func disableButton(_ button: UIButton) {
        button.backgroundColor = Constants.defaultBackgroundColor
        button.setTitleColor(Constants.defaultFontColor, for: .normal)
        button.layer.borderColor = Constants.defaultBorderColor?.cgColor
    }
    
    fileprivate func enableButton(_ button: UIButton) {
        button.backgroundColor = Constants.selectedBackgroundColor
        button.setTitleColor(Constants.selectedFontColor, for: .normal)
        button.layer.borderColor = Constants.selectedBorderColor?.cgColor
    }
    
    // MARK: - Actions
    
    @IBAction func onLeftButtonClicked(button: UIButton) {
        delegate?.categoryCell(cell: self, didClickedOnLeft: button)
    }
    
    @IBAction func onRightsButtonClicked(button: UIButton) {
        delegate?.categoryCell(cell: self, didClickedOnRight: button)
    }
}
