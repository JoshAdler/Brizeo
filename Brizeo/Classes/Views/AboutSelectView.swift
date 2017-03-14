//
//  AboutSelectView.swift
//  Brizeo
//
//  Created by Roman Bayik on 1/30/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import ChameleonFramework

protocol AboutSelectViewDelegate: class {
    func aboutSelectedViewDidClicked(view: AboutSelectView)
}

class AboutSelectView: UIView {

    // MARK: - Types
    
    struct Constants {
        static let selectedColor = HexColor("1f4ba5")!
        static let defaultColor = HexColor("e1e1e1")!
        static let borderWidth: CGFloat = 3.0
    }
    
    // MARK: - Properties

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var internalView: UIView! {
        didSet {
            internalView.backgroundColor = Constants.selectedColor
            internalView.isHidden = true
        }
    }
    
    weak var delegate: AboutSelectViewDelegate?
    
    var isSelected: Bool {
        get {
            return !internalView.isHidden
        }
        set {
            let color = newValue == true ? Constants.selectedColor.cgColor : Constants.defaultColor.cgColor
            
            layer.borderColor = color
            internalView.isHidden = !newValue
        }
    }
    
    // MARK: - Override methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.borderColor = Constants.defaultColor.cgColor
        layer.borderWidth = Constants.borderWidth
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = frame.width / 2.0
        
        if internalView != nil {
            internalView.layer.cornerRadius = internalView.frame.width / 2.0
        }
        
        if button != nil {
            button.layer.cornerRadius = button.frame.width / 2.0
        }
    }
    
    // MARK: - Actions
    
    @IBAction func onViewClicked(_ sender: UIButton) {
        delegate?.aboutSelectedViewDidClicked(view: self)
    }
}
