//
//  GenderViewController.swift
//  Brizeo
//
//  Created by Roman Bayik on 1/28/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit

class GenderViewController: BasicViewController {

    // MARK: - Types
    
    struct Constants {
        static let headerViewId = "HeaderView"
        static let cellId = "SettingsCheckmarkCell"
        
        static let headerViewHeight: CGFloat = 54.0
        static let footerViewHeight: CGFloat = 15.0
        static let cellViewHeight: CGFloat = 54.0
        
        static let sectionTitles = [
            LocalizableString.IamA.localizedString.uppercased(),
            LocalizableString.SearchForOneOrMore.localizedString.uppercased()
        ]
    }
    
    // MARK: - Properties
    
    @IBOutlet weak var tableView: UITableView!
    var user: User!
    var preferences: Preferences!
    
    // MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Helper.initialNavigationController().setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UserProvider.updateUser(user: UserProvider.shared.currentUser!, completion: nil)
        PreferencesProvider.updatePreferences(preferences: preferences, completion: nil)
    }
    
    // MARK: - Private methods
    
    fileprivate func registerViews() {
        tableView.register(UINib(nibName: "SettingsBigHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: Constants.headerViewId)
    }
}

// MARK: - UITableViewDataSource
extension GenderViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 /* "I am a" & "Search for one or more" */
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellId, for: indexPath) as! SettingsCheckmarkCell
        
        if indexPath.section == 0 { // I am
            let gender = Gender.gender(for: indexPath.row)
            
            cell.titleLabel.text = gender.titleSingle
            cell.isChecked = gender == user.gender
            
            return cell
        } else { // gender search
            let gender = Gender.gender(for: indexPath.row)
            
            cell.titleLabel.text = gender.titlePlural
            cell.isChecked = preferences.genders.contains(gender)
            
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension GenderViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: Constants.headerViewId) as! SettingsBigHeaderView
        
        view.titleLabel.text = Constants.sectionTitles[section]
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: Constants.headerViewId) as! SettingsBigHeaderView
        
        view.titleLabel.text = nil
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.cellViewHeight
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 1 { // last section
            return Constants.footerViewHeight
        }
        return 0.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.headerViewHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 { // I am
            user.gender = Gender.gender(for: indexPath.row)
            tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            
            UserProvider.updateUser(user: UserProvider.shared.currentUser!, completion: nil)
        } else { // search gender
            let gender = Gender.gender(for: indexPath.row)
            
            if preferences.genders.contains(gender) {
                if preferences.genders.count > 1 { // won't allow to remove the last search gender
                    preferences.genders.remove(at: preferences.genders.index(of: gender)!)
                }
            } else {
                preferences.genders.append(gender)
            }
            
            tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
            PreferencesProvider.updatePreferences(preferences: preferences, completion: nil)
        }
    }
}
