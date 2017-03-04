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
        
        static let headerViewCoef: CGFloat = 73.0 / 750.0
        static let footerViewCoef: CGFloat = 32.0 / 750.0
        static let cellViewCoef: CGFloat = 94.0 / 750.0
        
        static let sectionTitles = [
            LocalizableString.IamA.localizedString.uppercased(),
            LocalizableString.SearchForOneOrMore.localizedString.uppercased()
        ]
    }
    
    // MARK: - Properties
    
    @IBOutlet weak var tableView: UITableView!
    var user: User!
    var preferences: Preferences!
    var searchGenders: [Gender] = [.Man, .Couple]
    
    // MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerViews()
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
    //TODO: rewrite table view header/footer views
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellId, for: indexPath) as! SettingsCheckmarkCell
        
        if indexPath.section == 0 { // I am
            let gender = Gender.gender(for: indexPath.row)
            
            cell.titleLabel.text = gender.title
            cell.isChecked = gender == user.gender
            return cell
        } else { // gender search
            let gender = Gender.gender(for: indexPath.row)
            
            cell.titleLabel.text = gender.title
            cell.isChecked = /*preferences.genders*/searchGenders.contains(Gender.gender(for: indexPath.row))
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
        return Constants.cellViewCoef * tableView.bounds.width
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 1 { // last section
            return Constants.footerViewCoef * tableView.bounds.width
        }
        return 0.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.headerViewCoef * tableView.bounds.width
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 { // I am
            user.gender = Gender.gender(for: indexPath.row)
            tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        } else { // search gender
            let gender = Gender.gender(for: indexPath.row)
            
            if searchGenders.contains(gender) {
                if searchGenders.count > 1 { // won't allow to remove the last search gender
                    searchGenders.remove(at: searchGenders.index(of: gender)!)
                }
            } else {
                searchGenders.append(gender)
            }
            tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
        }
    }
}
