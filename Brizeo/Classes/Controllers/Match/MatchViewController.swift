//
//  MatchViewController.swift
//  Brizeo
//
//  Created by Roman Bayik on 2/13/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit

class MatchViewController: BasicViewController {

    // MARK: - Properties
    
    @IBOutlet weak var profileImageView: UIImageView! {
        didSet {
            profileImageView.layer.cornerRadius = profileImageView.frame.width / 2.0
        }
    }
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var returnButton: UIButton!
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
    }
    
    @IBAction func onReturnButtonClicked(sender: UIButton) {
        
    }
}
