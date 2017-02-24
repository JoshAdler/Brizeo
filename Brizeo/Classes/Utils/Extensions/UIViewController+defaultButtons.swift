//
//  UIViewController+defaultButtons.swift
//  Brizeo
//
//  Created by Giovanny Orozco on 4/15/16.
//  Copyright © 2016 Kogi Mobile. All rights reserved.
//

import UIKit
import SVProgressHUD

extension UIViewController {
    
//    private static var doOnce: () {
//        
//        let originalSelector = #selector(UIViewController.viewDidLoad)
//        let swizzledSelector = #selector(UIViewController.swizzled_viewDidLoad)
//        
//        let originalMethod = class_getInstanceMethod(self, originalSelector)
//        let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
//        let didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
//        
//        if didAddMethod {
//            class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
//        } else {
//            method_exchangeImplementations(originalMethod, swizzledMethod)
//        }
//    }
    
//    open override class func initialize() {
//        
//        // make sure this isn't a subclass
//        if self !== UIViewController.self {
//            return
//        }
//        self.doOnce
//    }
    
//    // MARK: - Method Swizzling
//    func swizzled_viewDidLoad() {
//     
//        swizzled_viewDidLoad()
//        
//        if let navigationController = navigationController {
//        
//            let index = navigationController.viewControllers.index(of: self)
//            navigationItem.backBarButtonItem = UIBarButtonItem(title: LocalizableString.Back.localizedString, style: .plain, target: nil, action: nil)
//
//            if index == 0/* && navigationController.isKind(of: DefaultNavigationController.self)*/ {
//                let image = BrizeoImage.SearchIcon.image.withRenderingMode(.alwaysOriginal)
//                navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(leftNavigationButtonTapped))
//                let image1 = BrizeoImage.SettingIcon.image.withRenderingMode(.alwaysOriginal)
//                navigationItem.leftBarButtonItem = UIBarButtonItem(image: image1, style: .plain, target: self, action: #selector(rightNavigationButtonClicked))
//            }
//        }
//    }
    
//    //MARK: - Utils
//    func leftNavigationButtonTapped() {
//        
//        //override this method
////        PFQuery *pushQuery = [PFInstallation query];
////        [pushQuery whereKey:@"deviceType" equalTo:@"ios"];
////        
////        // Send push notification to query
////        [PFPush sendPushMessageToQueryInBackground:pushQuery
////        withMessage:@"Hello World!"];
//    }
//    
//    func rightNavigationButtonClicked() {
//        //override this method
//    }
}

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

// MARK: UIKeyboard
extension UIViewController {
    
    func addDismissKeyboardGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGestureRecognizer.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
