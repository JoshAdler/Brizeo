//
//  UIViewController+defaultButtons.swift
//  Brizeo
//
//  Created by Giovanny Orozco on 4/15/16.
//  Copyright © 2016 Kogi Mobile. All rights reserved.
//

import UIKit
import SVProgressHUD

// MARK: AlertView
extension UIViewController {
    
    func showAlert(_ title: String, message: String, dismissTitle: String, completion: (() -> Void)?) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: dismissTitle, style: .default) { (action) in
            completion?()
        }
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func showAlertWith(_ title: String, message: String, dismissTitle: String, actionTitle: String, completionDismiss: (() -> Void)?, completionCancel: (() -> Void)?) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: dismissTitle, style: .default) { (action) in
            completionDismiss?()
        }
        let mainAction = UIAlertAction(title: actionTitle, style: .cancel) { (action) in
            completionCancel?()
        }
        alertController.addAction(defaultAction)
        alertController.addAction(mainAction)
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: Loader

extension UIViewController {
    
    func showBlackLoader() {
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.show()
    }
    
    func hideLoader() {
        SVProgressHUD.dismiss()
    }
    
    func showSuccessMessage() {
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.showSuccess(withStatus: LocalizableString.UserSaved.localizedString)
    }
}
