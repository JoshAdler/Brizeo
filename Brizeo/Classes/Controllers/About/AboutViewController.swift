//
//  AboutViewController.swift
//  Brizeo
//
//  Created by Roman Bayik on 1/30/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import ChameleonFramework
import SVProgressHUD
import Typist

class AboutViewController: UIViewController {
    
    // MARK: - Types
    
    struct Constants {
        static let placeholderTextColor = HexColor("dbdbdb")
        static let defaultTextColor = UIColor.black
        static let headerViewHeight: CGFloat = 54.0
    }
    
    enum Sections: Int {
        case passions = 0
        case nationality
        case work
        case education
        case introduceYourself
        
        var title: String? {
            switch self {
            case .passions:
                return LocalizableString.SelectInterests.localizedString.uppercased()
            case .nationality:
                return LocalizableString.SelectNationality.localizedString.uppercased()
            case .introduceYourself:
                return LocalizableString.IntroduceYourself.localizedString.uppercased()
            case .work:
                return LocalizableString.Work.localizedString.uppercased()
            case .education:
                return LocalizableString.Education.localizedString.uppercased()
            }
        }
        
        var height: CGFloat {
            return Constants.headerViewHeight
        }
        
        var headerViewId: String {
            return "SettingsBigHeaderView"
        }
        
        func cellHeight(for row: Int, hasPassions: Bool = true) -> CGFloat {
            switch self {
            case .passions:
                if hasPassions {
                    return 104.0
                } else {
                    return 55.0
                }
                /* RB Comment: old functionality
                if row == 0 {
                    return 53.0
                } else {
                    return 71.0
                }
 */
            case .introduceYourself:
                if row == 0 {
                    return 189.0
                } else {
                    return 104.0
                }
            case .work, .education, .nationality:
                return 55.0
            }
            
        }
        
        func cellId(for row: Int, hasPassions: Bool = true) -> String {
            switch self {
            case .passions:
                
                return hasPassions ? AboutPassionsTableViewCell.identifier : SettingsInvitationCell.identifier
                /* RB Comment: Old functionality
                if row == 0 {
                    return "AboutTitleTableViewCell"
                } else {
                    return AboutTableViewCell.identifier
                } */
            case .introduceYourself:
                if row == 0 {
                    return AboutInputTableViewCell.identifier
                } else {
                    return AboutSaveTableViewCell.identifier
                }
            case .work, .education, .nationality:
                return SettingsInvitationCell.identifier
            }
        }
    }
    
    // MARK: - Properties
    
    @IBOutlet weak var passionsTableView: UITableView!
    
    var user: User!
    var isSelected = false
    
    fileprivate var mutualFriends = [(name:String, pictureURL:String)]()
    fileprivate var selectedPassion = [String: Int]()
    fileprivate var passions: [Passion]?
    fileprivate var keyboardTypist: Typist!
    fileprivate var defaultTableViewContentHeight: CGFloat = -1.0
    
    // MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerHeaderViews()
        fetchPassions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // reload passions
        passionsTableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        configureKeyboardBehaviour()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UserProvider.updateUser(user: UserProvider.shared.currentUser!, completion: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Observers
    
    @objc func keyboardWillShowForResizing(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let _ = self.view.window?.frame {
            
            self.passionsTableView.contentSize = CGSize(width: self.passionsTableView.contentSize.width, height: self.defaultTableViewContentHeight + keyboardSize.height)
        } else {
            
            debugPrint("We're showing the keyboard and either the keyboard size or window is nil: panic widely.")
        }
    }
    
    @objc func keyboardWillHideForResizing(notification: NSNotification) {
        if ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            
            self.passionsTableView.contentSize = CGSize(width: self.passionsTableView.contentSize.width, height: self.defaultTableViewContentHeight)
        } else {
            
            debugPrint("We're about to hide the keyboard and the keyboard size is nil. Now is the rapture.")
        }
    }
    
    // MARK: - Public methods
    
    func reloadData() {
        passionsTableView.reloadData()
    }
    
    // MARK: - Private methods
    
    fileprivate func registerHeaderViews() { 
        passionsTableView.register(UINib(nibName: SettingsBigHeaderView.nibName, bundle: nil), forHeaderFooterViewReuseIdentifier: SettingsBigHeaderView.nibName)
    }
    
    fileprivate func configureKeyboardBehaviour() {
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShowForResizing(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHideForResizing(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)
    }
    
    fileprivate func normalizeUsersPassions() {
        
        // we need to check whether user has their selected passions that are not available on the database
        let availableIds = passions!.map({ return $0.objectId! })
        let availablePassions = user.passionsIds.filter({ return availableIds.contains($0) })
        
        user.passionsIds = availablePassions
        UserProvider.updateUser(user: user, completion: nil)
    }
    
    /* RB Comment: Old functionality
    fileprivate func setSelectedPassions() {
        
        guard (passions?.count)! >= 3 else {
            print("Error: can't operate selected passions with < 3 passions")
            return
        }
        
        // init selected passions
        let ids = user.passionsIds
        if ids.count == 0 { // set default passions
            // try to set travel, foodie and fitness
            if let travelPassion = passions!.filter({ $0.displayName == "Travel" }).first {
                selectedPassion[travelPassion.objectId] = 0
            }
            
            if let travelPassion = passions!.filter({ $0.displayName == "Foodie" }).first {
                selectedPassion[travelPassion.objectId] = 1
            }
            
            if let travelPassion = passions!.filter({ $0.displayName == "Fitness" }).first {
                selectedPassion[travelPassion.objectId] = 2
            }
        } else {
            for i in 0 ..< ids.count {
                selectedPassion[ids[i]] = i
            }
        }
        
        if selectedPassion.count < 3 {
            for i in 0 ..< (3 - selectedPassion.count) {
                let restPassions = passions!.filter({ !Array(selectedPassion.keys).contains($0.objectId) })
                selectedPassion[restPassions.first!.objectId] = selectedPassion.count + i
            }
        }
    
        user.assignPassionIds(dict: selectedPassion)
        
//        var idss = [String]()
//        for i in 0 ..< 4 {
//            idss.append(passions![i].objectId)
//        }
//        user.passionsIds = [String]()
        UserProvider.updateUser(user: user, completion: nil)
    }
 */
    
    fileprivate func fetchPassions() {
        PassionsProvider.shared.retrieveAllPassions(true, type: .extended) { [weak self] (result) in
            if let welf = self {
                
                DispatchQueue.main.async {
                    switch result {
                    case .success(let passions):
                        
                        welf.passions = passions
                        //welf.setSelectedPassions()
                        welf.normalizeUsersPassions()
                        
                        welf.passionsTableView.reloadData()
                        
                        break
                    case .failure(let error):
                        
                        welf.showAlert(LocalizableString.Error.localizedString, message: error.localizedDescription, dismissTitle: LocalizableString.Dismiss.localizedString) {
                            welf.fetchPassions()
                        }
                        
                        break
                    default:
                        break
                    }
                }
            }
        }
    }
}

// MARK: - UITextViewDelegate
extension AboutViewController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        if defaultTableViewContentHeight == -1.0 {
            defaultTableViewContentHeight = passionsTableView.contentSize.height
        }
        
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        user.personalText = textView.text
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        user.personalText = textView.text
        
        return true
    }
}

// MARK: - UITableViewDataSource
extension AboutViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Sections(rawValue: section) else {
            return 0
        }
        
        switch (section) {
        case .introduceYourself:
            return 2
        case .passions:
            if passions != nil {
                return 1
            }
            return 0
        default: return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let section = Sections(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        
        let cellId = section.cellId(for: indexPath.row, hasPassions: user.passions.count == Configurations.General.requiredMinPassionsCount)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        switch section {
        case .passions:
            
            if user.passions.count != Configurations.General.requiredMinPassionsCount {
                
                let passionCell = cell as! SettingsInvitationCell
                passionCell.titleLabel.text = LocalizableString.Select.localizedString
                
                return passionCell
            }
            
            let passionCell = cell as! AboutPassionsTableViewCell
            var passions = [Passion]()
            
            _ = user.passionsIds.map({
                if let passion = PassionsProvider.shared.getPassion(by: $0, with: .extended) {
                    passions.append(passion)
                }
            })
            
            if passions.count == Configurations.General.requiredMinPassionsCount {
                passionCell.setPassions(passions)
            }
            
            return passionCell
            /* RB Comment: old functionality
            if indexPath.row == 0 {
                return cell
            } else {
                let typeCell = cell as! AboutTableViewCell
                let passion = passions![indexPath.row]
                
                typeCell.delegate = self
                typeCell.titleLabel.text = passion.displayName
                
                if let index = selectedPassion[passion.objectId] {
                    typeCell.selectedIndex = index
                } else {
                    typeCell.selectedIndex = -1
                }
                
                return typeCell
            }*/
        case .nationality:
            let typeCell = cell as! SettingsInvitationCell
            
            if let nationalityCode = user.nationality {
                
                let country = Country.initWith(nationalityCode)
                typeCell.titleLabel.text = country.name
            } else {
                
                typeCell.titleLabel.text = "Not set."
            }
            
            return typeCell
        case .introduceYourself:
            if indexPath.row == 0 {
                let typeCell = cell as! AboutInputTableViewCell
                
                typeCell.textView.delegate = self
                typeCell.textView.text = user.personalText
                
                return typeCell
            } else {
                let typeCell = cell as! AboutSaveTableViewCell
               typeCell.delegate = self
                
                return typeCell
            }
        case .work:
            let typeCell = cell as! SettingsInvitationCell
            
            typeCell.titleLabel.text = user.workInfo ?? "Not set."
            
            return typeCell
        case .education:
            let typeCell = cell as! SettingsInvitationCell
            
            typeCell.titleLabel.text = user.studyInfo ?? "Not set."
            
            return typeCell
        }
    }
}

// MARK: - UITableViewDelegate
extension AboutViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard let section = Sections(rawValue: indexPath.section) else {
            return 0.0
        }
        
        return section.cellHeight(for: indexPath.row, hasPassions: user.passions.count == Configurations.General.requiredMinPassionsCount)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let section = Sections(rawValue: section) else {
            return 0.0
        }
        return section.height
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let section = Sections(rawValue: section) else {
            return nil
        }
        
        let headerView: SettingsHeaderView = tableView.dequeueReusableHeaderFooterView(withIdentifier: section.headerViewId)
        
        headerView.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: tableView.frame.width, height: section.height))
        headerView.titleLabel.text = section.title
        headerView.titleLabel.textColor = HexColor("5f5f5f")!
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let section = Sections(rawValue: indexPath.section) else {
            return
        }
        
        if section == .introduceYourself {
            return
        }
        
        if section == .nationality {
            
            let controller: OptionsNationalityViewController = Helper.controllerFromStoryboard(controllerId: "OptionsNationalityViewController")!
            controller.user = user
            
            Helper.currentTabNavigationController()?.pushViewController(controller, animated: true)
        } else if section == .passions {
            
            let controller: CategoriesViewController = Helper.controllerFromStoryboard(controllerId: "CategoriesViewController")!
            controller.user = user
            
            Helper.currentTabNavigationController()?.pushViewController(controller, animated: true)
        } else {
            
            switch section {
            case .work:
                
                let controller: OptionsViewController = Helper.controllerFromStoryboard(controllerId: "OptionsViewController")!
                controller.type = .work
                controller.user = user
                
                Helper.currentTabNavigationController()?.pushViewController(controller, animated: true)
                break
            case .education:
                
                let controller: OptionsEducationViewController = Helper.controllerFromStoryboard(controllerId: "OptionsEducationViewController")!
                controller.user = user
                
                Helper.currentTabNavigationController()?.pushViewController(controller, animated: true)
                break
            default:
                break
            }
        }
    }
}

// MARK: - AboutTableViewCellDelegate
extension AboutViewController: AboutTableViewCellDelegate {
    
    func aboutTableViewCell(_ cell: AboutTableViewCell, onSelectViewClicked index: Int) {
        guard let indexPath = passionsTableView.indexPath(for: cell) else {
            assertionFailure("No index path for cell")
            return
        }
        
        var pastPassionId: String? /* get the current interest with the selected index */
        let newPassionId = passions![indexPath.row].objectId!
        
        for (passionId, _index) in selectedPassion {
            if _index == index {
                pastPassionId = passionId
                break
            }
        }
        
        if let alreadySelectedIndex = selectedPassion[newPassionId] {
            
            selectedPassion[newPassionId] = index
            
            if pastPassionId != nil {
                selectedPassion[pastPassionId!] = alreadySelectedIndex
            }
        } else {
            if pastPassionId != nil {
                selectedPassion[pastPassionId!] = nil
            }
            selectedPassion[newPassionId] = index
        }
        
        passionsTableView.reloadData()
        
        user.assignPassionIds(dict: selectedPassion)
        UserProvider.updateUser(user: user, completion: nil)
        
        // notify about changes
        Helper.sendNotification(with: searchLocationChangedNotification, object: nil, dict: nil)
    }
}

// MARK: - AboutSaveTableViewCellDelegate
extension AboutViewController: AboutSaveTableViewCellDelegate {
    
    func aboutSaveCell(cell: AboutSaveTableViewCell, didClickedOnSave button: UIButton) {
        
        view.endEditing(true)
        
        showBlackLoader()
        
        UserProvider.updateUser(user: user) { (result) in
            switch(result) {
            case .success(_):
                
                SVProgressHUD.showSuccess(withStatus: LocalizableString.Success.localizedString)
                break
            case .failure(let error):
                
                SVProgressHUD.showError(withStatus: error.localizedDescription)
                break
            default:
                break
            }
        }
    }
}
