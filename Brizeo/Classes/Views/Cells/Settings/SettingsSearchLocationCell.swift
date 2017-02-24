//
//  SearchLocationTableViewCell.swift
//  Brizeo
//
//  Created by Arturo on 5/2/16.
//  Copyright © 2016 Kogi Mobile. All rights reserved.
//

import UIKit
import CoreLocation

protocol SettingsSearchLocationCellDelegate: class {
    
    func searchLocationCell(_ searchLocationCell: SettingsSearchLocationCell, textSuggestionsForText text: String, completion:(([String]) -> Void)?)
    func searchLocationCell(_ searchLocationCell: SettingsSearchLocationCell, didSelectText text: String)
}

class SettingsSearchLocationCell: UITableViewCell {

    // MARK: - Properties
    
    @IBOutlet weak var textField : AutoCompleteTextField!
    weak var delegate : SettingsSearchLocationCellDelegate?
    
    // MARK: - Public methods
    
    func setupTextField(_ superView: UIView) {
        textField!.placeholder = LocalizableString.AddLocation.localizedString
        textField!.delegate = self
        textField!.autoCompleteTextFont = UIFont(name: "HelveticaNeue-Light", size: 12)!
        textField!.autoCompleteTextColor = UIColor.darkGray
        textField!.autoCompleteCellHeight = 35.0
        textField!.maximumAutoCompleteCount = 20
        textField!.hidesWhenSelected = true
        textField!.hidesWhenEmpty = true
        textField!.enableAttributedText = true
        var attributes = [String:AnyObject]()
        attributes[NSForegroundColorAttributeName] = UIColor.black
        attributes[NSFontAttributeName] = UIFont(name: "HelveticaNeue-Bold", size: 12.0)
        textField!.autoCompleteAttributes = attributes
        textField!.onSelect = {[weak self] text, indexpath in
            
            if let welf = self {
                welf.textField!.text = text
                welf.textField!.resignFirstResponder()
            }
        }
        textField!.onTextChange = {[weak self] text in
            
            if let welf = self {
                welf.delegate?.searchLocationCell(welf, textSuggestionsForText: welf.textField!.text!, completion: { [weak self] (suggestions) in
                    
                    if let welf = self {
                        welf.textField!.autoCompleteStrings = suggestions
                    }
                    })
            }
        }
    }
}

// MARK: - UITextFieldDelegate
extension SettingsSearchLocationCell: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        delegate?.searchLocationCell(self, didSelectText: textField.text!)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        return true
    }
}
