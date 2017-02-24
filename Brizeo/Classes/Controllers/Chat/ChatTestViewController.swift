//
//  ChatTestViewController.swift
//  Brizeo
//
//  Created by Roman Bayik on 2/24/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit

class ChatTestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let chatManager : ALChatManager = ALChatManager(applicationKey: "324a31b8f131bb0d6f69f9164f3a7cfd6")
        chatManager.registerUserAndLaunchChat(ALChatManager.getUserDetail(), fromController: self, forUser:nil)
    }
}
