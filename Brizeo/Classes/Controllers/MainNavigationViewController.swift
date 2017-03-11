//
//  MainNavigationViewController.swift
//  Brizeo
//
//  Created by Roman Bayik on 1/27/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import MessageUI
import Social

class MainNavigationViewController: UINavigationController {
    
    // MARK: - Properties
    
    var loadingView: UIView?
    
    // MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.isTranslucent = false
        navigationBar.barStyle = .default
    }
    
    // MARK: - Public methods
    
    func presentHalfBlackView(isVisible: Bool) {
        if loadingView == nil {
            loadingView = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)))
            loadingView!.backgroundColor = UIColor.black.withAlphaComponent(0.75)
            loadingView?.isHidden = true
            view.addSubview(loadingView!)
        }
        
        view.isHidden = !isVisible
    }
}

// MARK: - MFMailComposeViewControllerDelegate
extension MainNavigationViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

// MARK: - MFMessageComposeViewControllerDelegate
extension MainNavigationViewController: MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}
