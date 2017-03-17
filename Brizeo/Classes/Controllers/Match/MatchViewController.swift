//
//  MatchViewController.swift
//  Brizeo
//
//  Created by Roman Bayik on 2/13/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import ChameleonFramework

class MatchViewController: BasicViewController {

    // MARK: - Properties
    
    @IBOutlet weak var profileImageView: UIImageView! {
        didSet {
            profileImageView.layer.cornerRadius = profileImageView.frame.width / 2.0
            profileImageView.layer.borderWidth = 2.0
            profileImageView.layer.borderColor = UIColor.white.cgColor
        }
    }
    @IBOutlet weak var chatButton: UIButton! {
        didSet {
            chatButton.layer.cornerRadius = 7.0
        }
    }
    @IBOutlet weak var returnButton: UIButton! {
        didSet {
            returnButton.layer.cornerRadius = 7.0
            returnButton.layer.borderColor = HexColor("2f9bd6")!.cgColor
            returnButton.layer.borderWidth = 2.0
        }
    }
    var user: User!
    
    // MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = user.profileUrl {
            profileImageView.sd_setImage(with: url)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func onChatButtonClicked(sender: UIButton) {
        ChatProvider.startChat(with: user.objectId, from: self)
        
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onReturnButtonClicked(sender: UIButton) {
        _ = navigationController?.popViewController(animated: true)
    }
}
