//
//  ConfirmationView.swift
//  Brizeo
//
//  Created by Roman Bayik on 2/13/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit

class ConfirmationView: UIView {
    
    // MARK: - Types
    
    struct Constants {
        static let animationDuration = 0.3
    }
    
    // MARK: - Properties
    
    @IBOutlet weak var okButton: UIButton! {
        didSet {
            okButton.setTitle(LocalizableString.Ok.localizedString.uppercased(), for: .normal)
        }
    }
    @IBOutlet weak var cancelButton: UIButton! {
        didSet {
            cancelButton.setTitle(LocalizableString.Cancel.localizedString, for: .normal)
        }
    }
    @IBOutlet weak var centerView: UIView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var textLabel: UILabel! {
        didSet {
            textLabel.text = LocalizableString.ConfirmationText.localizedString
        }
    }
    
    // MARK: - Override methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        centerView.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        backgroundView.alpha = 0.0
    }
    
    // MARK: - Public methods
    
    func present(on view: UIView) {
        frame = CGRect(origin: CGPoint.zero, size: view.frame.size)
        view.addSubview(self)
        
        UIView.animate(withDuration: Constants.animationDuration) {
            self.centerView.transform = CGAffineTransform.identity
            self.backgroundView.alpha = 1.0
        }
    }
    
    // MARK: - Actions
    
    @IBAction func onOkButtonClicked(sender: UIButton) {
        self.removeFromSuperview()
    }
    
    @IBAction func onCancelButtonClicked(sender: UIButton) {
        self.removeFromSuperview()
    }
}
