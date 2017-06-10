//
//  OptionsNationalityViewController.swift
//  Brizeo
//
//  Created by Roman Bayik on 6/10/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import SWTableViewCell
import ChameleonFramework

enum OptionsNationalitySource {
    case about
    case search
}

class OptionsNationalityViewController: BasicViewController {
    
    // MARK: - Types
    
    struct Constants {
        static let searchBarHeight: CGFloat = 73.0
    }
    
    // MARK: - Properties
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var activityIndicator: UIActivityIndicatorView!
    
    var user: User!
    var preferences: Preferences?
    var source: OptionsNationalitySource = .about
    
    fileprivate var searchBar: CustomSearchBar?
    fileprivate var filteredCountries: [Country]?
    
    // MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        filterContentForSearchText(searchText: "")
        
        searchBar = CustomSearchBar(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: view.frame.width, height: Constants.searchBarHeight)))
        searchBar?.delegate = self
        searchBar?.placeholder = source == .about ? LocalizableString.SelectNationalitySearchBar.localizedString : LocalizableString.SelectNationalityToSearch.localizedString
        
        tableView.tableHeaderView = searchBar
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        activityIndicator.stopAnimating()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        view.endEditing(true)
        
        if preferences != nil {
            PreferencesProvider.updatePreferences(preferences: preferences!, completion: nil)
        }
    }
    
    override func onBackButtonClicked(sender: UIBarButtonItem?) {
        
        guard let navigationController = navigationController else {
            return
        }
        
        guard let tabsController = navigationController.viewControllers[navigationController.viewControllers.count - 2] as? PersonalTabsViewController else {
            return
        }
        
        if source == .search {
            
            UserProvider.updateUser(user: UserProvider.shared.currentUser!, completion: nil)
            
            if preferences != nil {
                PreferencesProvider.updatePreferences(preferences: preferences!, completion: nil)
            }
            
            _ = self.navigationController?.popViewController(animated: true)
            return
        }
        
        let aboutController = tabsController.detailsController.aboutController
        
        aboutController?.user = user
        aboutController?.passionsTableView.reloadData()
        
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Private methods
    
    fileprivate func loadAllCountries() -> [Country] {
        var countries = [Country]()
        
        for code in Locale.isoRegionCodes {
            countries.append(Country.initWith(code))
        }
        
        countries.sort(by: { return $0.name < $1.name })
        
        return countries
    }
//    }
//    
//    fileprivate func configureKeyboardBehaviour() {
//        keyboardTypist = Typist()
//        
//        keyboardTypist
//            .on(event: .willHide, do: { (options) in
//                
//                print("Will hide on trips")
//                self.tableViewBottomConstraint.constant = 0
//            })
//            .on(event: .willShow, do: { (options) in
//                
//                print("Will show on trips")
//                self.tableViewBottomConstraint.constant = options.endFrame.height
//            })
//            .start()
//    }
    
    fileprivate func filterContentForSearchText(searchText: String) {
        if searchText.numberOfCharactersWithoutSpaces() == 0 {
            
            if source == .search {
                filteredCountries = [Country.emptyCoutry()] + loadAllCountries()
            } else {
                filteredCountries = loadAllCountries()
            }
        } else {
            filteredCountries = loadAllCountries().filter {
                $0.name.lowercased().contains(searchText.lowercased())
            }
        }
        
        tableView.reloadData()
    }
    
    fileprivate func isSearchBarActive() -> Bool {
        return searchBar?.isFirstResponder ?? false
    }
    
    fileprivate func hideSearchBar() {
        searchBar?.endEditing(true)
        searchBar?.showsCancelButton = false
        searchBar?.setNeedsDisplay()
        searchBar?.text = nil
        filteredCountries = loadAllCountries()
        
        tableView.reloadData()
    }
    
    // MARK: - Observers
    
    func keyboardWasShown(_ notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.tableViewBottomConstraint.constant = keyboardSize.height
        }
    }
    
    func keyboardWillBeHidden(_ notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.tableViewBottomConstraint.constant = 0
        }
    }
}

// MARK: - UISearchControllerDelegate
extension OptionsNationalityViewController: UISearchControllerDelegate {
    
    func didDismissSearchController(_ searchController: UISearchController) {
        filteredCountries = loadAllCountries()
        tableView.reloadData()
    }
}

// MARK: - UISearchBarDelegate
extension OptionsNationalityViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        filterContentForSearchText(searchText: searchBar.text!)
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        hideSearchBar()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterContentForSearchText(searchText: searchBar.text!)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        hideSearchBar()
    }
}

// MARK: - UITableViewDataSource
extension OptionsNationalityViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let filteredCountries = filteredCountries {
            return filteredCountries.count
        }
        return loadAllCountries().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: TripsTableViewCell.identifier, for: indexPath) as! TripsTableViewCell
        
        var country: Country
        if let filteredCountries = filteredCountries {
            country = filteredCountries[indexPath.row]
        } else {
            country = loadAllCountries()[indexPath.row]
        }
        
        cell.countryImageView.image = country.flagImage
        cell.countryNameLabel.text = country.name
        
        if source == .about {
            cell.isChecked = country.code == user.nationality
        } else if preferences != nil{
            cell.isChecked = country.code == preferences!.searchNationality
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension OptionsNationalityViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let filteredCountries = filteredCountries {
            let country = filteredCountries[indexPath.row]
            
            // save selected nationality
            if source == .about {
                user.nationality = country.code
            } else {
                preferences?.searchNationality = country.code
            }
            
            hideSearchBar()
            
            filterContentForSearchText(searchText: "")
            tableView.reloadData()
            
            // notify about changes
            Helper.sendNotification(with: searchLocationChangedNotification, object: nil, dict: nil)
            Helper.sendNotification(with: searchNationalityChangedNotification, object: nil, dict: nil)
            
            onBackButtonClicked(sender: nil)
        }
    }
}
