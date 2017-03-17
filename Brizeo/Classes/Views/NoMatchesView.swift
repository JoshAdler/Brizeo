//
//  NoDescriptionView.swift
//  Brizeo
//
//  Created by Roman Bayik on 2/13/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import ChameleonFramework

class NoMatchesView: UIView {

    // MARK: - Types
    
    struct Constants {
        static let animationDuration = 0.3
    }
    
    // MARK: - Properties
    
    @IBOutlet weak var okButton: UIButton! {
        didSet {
            okButton.setTitle(LocalizableString.Ok.localizedString.uppercased(), for: .normal)
            okButton.layer.cornerRadius = 7.0
            okButton.layer.borderWidth = 1.0
            okButton.layer.borderColor = HexColor("1f4ba5")!.cgColor
        }
    }
    @IBOutlet weak var cancelButton: UIButton! {
        didSet {
            cancelButton.setTitle(LocalizableString.Cancel.localizedString, for: .normal)
            cancelButton.layer.cornerRadius = 7.0
        }
    }
    @IBOutlet weak var centerView: UIView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var textLabel: UILabel! {
        didSet {
            textLabel.text = LocalizableString.NoMatchInstructions.localizedString
        }
    }
    @IBOutlet weak var topTextLabel: UILabel! {
        didSet {
            topTextLabel.text = LocalizableString.NoMatch.localizedString
        }
    }
    
    @IBOutlet weak var bottomTextLabel: UILabel! {
        didSet {
            bottomTextLabel.text = LocalizableString.NoMatchGoNext.localizedString
        }
    }
    
    fileprivate var confirmAction: ((Void) -> Void)?
    fileprivate var declineAction: ((Void) -> Void)?
    
    // MARK: - Override methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        centerView.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        backgroundView.alpha = 0.0
    }
    
    // MARK: - Public methods
    
    func present(on view: UIView, confirmAction: ((Void) -> Void)?, declineAction: ((Void) -> Void)?) {
        
        self.confirmAction = confirmAction
        self.declineAction = declineAction
        
        frame = CGRect(origin: CGPoint.zero, size: view.frame.size)
        view.addSubview(self)
        
        UIView.animate(withDuration: Constants.animationDuration) { 
            self.centerView.transform = CGAffineTransform.identity
            self.backgroundView.alpha = 1.0
        }
    }
    
    // MARK: - Actions
    
    @IBAction func onCancelButtonClicked(sender: UIButton) {
        self.removeFromSuperview()
        
        declineAction?()
    }
    
    @IBAction func onOkButtonClicked(sender: UIButton) {
        self.removeFromSuperview()
        
        confirmAction?()
    }
}
