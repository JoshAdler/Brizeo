//
//  TripsViewController.swift
//  Brizeo
//
//  Created by Roman Bayik on 1/30/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import SWTableViewCell
import ChameleonFramework

class TripsViewController: UIViewController {

    // MARK: - Types
    
    // MARK: - Properties

    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var activityIndicator: UIActivityIndicatorView!
    
    var user: User!
    
    fileprivate var countries = [Country]()
    fileprivate var filteredCountries: [Country]?
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadCountries()
        
        //if User.userIsCurrentUser(user) {
            searchController.searchResultsUpdater = self
            searchController.dimsBackgroundDuringPresentation = false
            searchController.delegate = self
            definesPresentationContext = true
            tableView.tableHeaderView = searchController.searchBar
            searchController.searchBar.placeholder = LocalizableString.SearchCountries.localizedString
        //}
        
        resizeViewWhenKeyboardAppears = true
        
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        activityIndicator.stopAnimating()
    }
    
    // MARK: - Private methods
    
    fileprivate func rightUtilityButtons() -> [AnyObject] {
        //if User.userIsCurrentUser(user) {
            let rightUtilityButtons = NSMutableArray()
        rightUtilityButtons.sw_addUtilitySpecialDeleteButton(with: HexColor("2f9bd6")!, title: LocalizableString.Delete.localizedString)
            return rightUtilityButtons as [AnyObject]
        //}
        //return []
    }
    
    fileprivate func loadCountries() {
        for code in Locale.isoRegionCodes {
            countries.append(Country.initWith(code))
        }
    }
    
    fileprivate func filterContentForSearchText(searchText: String) {
        if searchText.numberOfCharactersWithoutSpaces() == 0 {
            filteredCountries = countries
        } else {
            filteredCountries = countries.filter {
                $0.name.lowercased().contains(searchText.lowercased())
            }
        }
        
        tableView.reloadData()
    }
    
    // MARK: - Public methods
    
//    func saveUser() {
//        User.saveParseUser({ (result) in
//            
//            switch result {
//            case .success(): break
//            // Saved
//            case .failure(let error):
//                self.showAlert(LocalizableString.Error.localizedString, message: error, dismissTitle: LocalizableString.Ok.localizedString, completion: nil)
//                break
//            }
//        })
//    }
}

// MARK: - UISearchResultsUpdating
extension TripsViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}

// MARK: - UISearchControllerDelegate
extension TripsViewController: UISearchControllerDelegate {
    
    func didDismissSearchController(_ searchController: UISearchController) {
        filteredCountries = nil
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension TripsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let filteredCountries = filteredCountries {
            return filteredCountries.count
        }
        return user.countries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueReusableCell(withIdentifier: TripsTableViewCell.identifier, for: indexPath) as! TripsTableViewCell
        
        var country: Country
        if let filteredCountries = filteredCountries {
            country = filteredCountries[indexPath.row]
        } else {
            country = user.countries[indexPath.row]
        }
        
        cell.delegate = self
        cell.rightUtilityButtons = rightUtilityButtons()
        cell.countryImageView.image = country.flagImage
        cell.countryNameLabel.text = country.name

        return cell
    }
}

// MARK: - SWTableViewCellDelegate
extension TripsViewController: SWTableViewCellDelegate {
    
    func swipeableTableViewCellShouldHideUtilityButtons(onSwipe cell: SWTableViewCell!) -> Bool {
        return true
    }
    
    func swipeableTableViewCell(_ cell: SWTableViewCell!, didTriggerRightUtilityButtonWith index: Int) {
        
        if index == 0 {
            guard let indexPath = tableView.indexPath(for: cell) else {
                return
            }
            //TODO: check equal protocol for country
            let country = user.countries[indexPath.row]
            user.countries.remove(at: user.countries.index(of: country)!)
            //saveUser()
            //TODO: save user
            
            tableView.deleteRows(at: [indexPath], with: .top)
        }
    }
}

// MARK: - UITableViewDelegate
extension TripsViewController: UITableViewDelegate {
    
//    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
//        // TODO: check delete button
//        return LocalizableString.Delete.localizedString
//    }
    
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        return filteredCountries == nil
//    }
    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        
//        if editingStyle == .delete {
//            let country = Country.initWith(user.countries[indexPath.row])
//            user.countries.remove(at: user.countries.index(of: country.code)!)
//            saveUser()
//            tableView.deleteRows(at: [indexPath], with: .top)
//        }
//    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
//    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
//        return .delete
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let filteredCountries = filteredCountries {
            let country = filteredCountries[indexPath.row]
            if !user.countries.contains(country) {
                user.countries.append(country)
                // TODO: save user
                //saveUser()
                GoogleAnalyticsManager.userSelectCountry(country: country.name).sendEvent()
                searchController.isActive = false
                self.filteredCountries = nil
                tableView.reloadData()
            }
        }
    }
}
