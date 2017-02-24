//
//  LoginViewController.swift
//  Brizeo
//
//  Created by Giovanny Orozco on 4/18/16.
//  Copyright © 2016 Kogi Mobile. All rights reserved.
//

import UIKit
import SVProgressHUD
import Branch

class LoginViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var termsSwitch: UISwitch!
    
    //MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = LocationManager.shared.requestCurrentLocation(nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    //MARK: - Actions
    
    @IBAction func loginWithFbButtonPressed(_ sender: AnyObject) {
        guard termsSwitch.isOn else {
            SVProgressHUD.showError(withStatus: "You have to accept our Terms of Use.")
            return
        }
    
        UserProvider.logInUser(LocationManager.shared.currentLocationCoordinates, from: self) { [unowned self] (result) in
            switch (result) {
            case .success(let user):
                Branch.currentInstance.setIdentity("\(user.objectId!)-\(user.firstName) \(user.lastName)")
                User.checkUserRewards()
                self.validateBranchLink()
                self.hideLoader()
                
                _ = self.navigationController?.popViewController(animated: true)
            case .failure(let message):
                // Login canceled
                SVProgressHUD.showError(withStatus: message)
            }
        }
    }
    //TODO: check the place with loading
    
    @IBAction func termsButtonTapped(_ sender: UIButton) {
        let termsURL = URL(string: Configurations.General.termsOfUseURL)!
        Helper.openURL(url: termsURL)
    }
    
    // MARK: - Public methods
    
    func validateBranchLink() {
        let installParams = Branch.currentInstance.getFirstReferringParams()
        if let clickedOnLink = installParams?[BranchKeys.ClickedOnLink] as? Bool, let isFirstSession = installParams?[BranchKeys.IsFirstSession] as? Bool {
            
            if clickedOnLink && isFirstSession {
                Branch.currentInstance.userCompletedAction(BranchKeys.InstallAfterInvitation, withState: [String: String]())
            }
        }
    }
}
