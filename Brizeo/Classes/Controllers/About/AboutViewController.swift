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
        case work
        case education
        case introduceYourself
        
        var title: String? {
            switch self {
            case .passions:
                return LocalizableString.SelectInterests.localizedString.uppercased()
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
        
        func cellHeight(for row: Int) -> CGFloat {
            switch self {
            case .passions:
                if row == 0 {
                    return 53.0
                } else {
                    return 71.0
                }
            case .introduceYourself:
                if row == 0 {
                    return 189.0
                } else {
                    return 104.0
                }
            case .work, .education:
                return 55.0
            }
            
        }
        
        func cellId(for row: Int) -> String {
            switch self {
            case .passions:
                if row == 0 {
                    return "AboutTitleTableViewCell"
                } else {
                    return AboutTableViewCell.identifier
                }
            case .introduceYourself:
                if row == 0 {
                    return AboutInputTableViewCell.identifier
                } else {
                    return AboutSaveTableViewCell.identifier
                }
            case .work, .education:
                return SettingsInvitationCell.identifier
            }
        }
    }
    
    // MARK: - Properties
    
    @IBOutlet weak var passionsTableView: UITableView!
    
    var user: User!
    
    fileprivate var mutualFriends = [(name:String, pictureURL:String)]()
    fileprivate var selectedPassion = [String: Int]()
    fileprivate var passions: [Passion]?
    
    // MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerHeaderViews()
        
        fetchPassions()
//        fetchMutualFriends()
        
        configureKeyboardBehaviour()
        
//        // hide keyboard on click anywhere
//        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UserProvider.updateUser(user: UserProvider.shared.currentUser!, completion: nil)
    }
    
    // MARK: - Private methods
    
    fileprivate func registerHeaderViews() { 
        passionsTableView.register(UINib(nibName: SettingsBigHeaderView.nibName, bundle: nil), forHeaderFooterViewReuseIdentifier: SettingsBigHeaderView.nibName)
    }
    
    fileprivate func configureKeyboardBehaviour() {
        let keyboard = Typist.shared
        
        keyboard
            .on(event: .willHide, do: { (options) in
                UIView.animate(withDuration: options.animationDuration, delay: 0.0, options: UIViewAnimationOptions(rawValue: UInt(options.animationCurve.rawValue)), animations: {

                    self.passionsTableView.contentSize = CGSize(width: self.passionsTableView.contentSize.width, height: self.passionsTableView.contentSize.height - options.endFrame.height)
                }, completion: nil)
            })
            .on(event: .willShow, do: { (options) in
                UIView.animate(withDuration: options.animationDuration, delay: 0.0, options: UIViewAnimationOptions(rawValue: UInt(options.animationCurve.rawValue)), animations: {
                    
                    self.passionsTableView.contentSize = CGSize(width: self.passionsTableView.contentSize.width, height: self.passionsTableView.contentSize.height + options.endFrame.height)
                }, completion: nil)
            })
            .start()
    }
    
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
        UserProvider.updateUser(user: user, completion: nil)
    }
    
    fileprivate func fetchPassions() {
        PassionsProvider.shared.retrieveAllPassions(true) { [weak self] (result) in
            if let welf = self {
                
                DispatchQueue.main.async {
                    switch result {
                    case .success(let passions):
                        
                        welf.passions = passions
                        welf.setSelectedPassions()
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
    
    fileprivate func fetchMutualFriends() {
//        UserProvider.getMutualFriendsOfCurrentUser(User.current()!, andSecondUser: user, completion: { (result) in
//            switch result {
//            case .success(let value):
//                self.mutualFriends = value
//                self.delegate.mutualFriendsCount(value.count)
//                self.tableView.reloadSections(IndexSet(integer: Sections.mutualFriends.rawValue), with: UITableViewRowAnimation.automatic)
//            case .failure(let error):
//                self.showAlert(LocalizableString.Error.localizedString, message: error, dismissTitle: LocalizableString.Dismiss.localizedString, completion: nil)
//            }
//        })
    }
}

// MARK: - UITextViewDelegate
extension AboutViewController: UITextViewDelegate {}

// MARK: - UITableViewDataSource
extension AboutViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Sections(rawValue: section) else {
            return 0
        }
        
        switch (section) {
        case .introduceYourself:
            return 2
        case .passions:
            return passions?.count ?? 0 + 1
        default: return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let section = Sections(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        
        let cellId = section.cellId(for: indexPath.row)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        switch section {
        case .passions:
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
            }
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
        return section.cellHeight(for: indexPath.row)
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
        
        if section != .work && section != .education {
            return
        }
        
        let controller: OptionsViewController = Helper.controllerFromStoryboard(controllerId: "OptionsViewController")!
        
        switch section {
        case .work:
            controller.type = .work
            break
        case .education:
            controller.type = .education
            break
        default:
            break
        }
        
        controller.user = user
        Helper.currentTabNavigationController()?.pushViewController(controller, animated: true)
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
    }
}

// MARK: - AboutSaveTableViewCellDelegate
extension AboutViewController: AboutSaveTableViewCellDelegate {
    
    func aboutSaveCell(cell: AboutSaveTableViewCell, didClickedOnSave button: UIButton) {
        
        view.endEditing(true)
        
        showBlackLoader()
        
        let currentUser = UserProvider.shared.currentUser!
        UserProvider.updateUser(user: currentUser) { [weak self] (result) in
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
