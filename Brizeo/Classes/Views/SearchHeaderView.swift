//
//  SearchHeaderView.swift
//  Brizeo
//
//  Created by Roman Bayik on 8/30/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit

protocol SearchHeaderViewDelegate: UITextFieldDelegate {
    func searchHeader(_ view: SettingsHeaderView, didChanged text: String?)
}

class SearchHeaderView: SettingsHeaderView {

    // MARK: - Properties
    
    @IBOutlet weak var searchField: UITextField!
    weak var delegate: SearchHeaderViewDelegate? {
        didSet {
            
            if delegate != nil {
                searchField.delegate = delegate
            } else {
                searchField.delegate = nil
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func textFieldValueWasChanged(textField: UITextField) {
        
        delegate?.searchHeader(self, didChanged: textField.text)
    }
}
