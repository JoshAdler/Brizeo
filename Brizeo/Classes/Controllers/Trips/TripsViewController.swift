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
    
    struct Constants {
        static let searchBarHeight: CGFloat = 73.0
    }
    
    // MARK: - Properties

    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var activityIndicator: UIActivityIndicatorView!
    
    var user: User!

    fileprivate var searchBar: TripSearchBar?
    fileprivate var filteredCountries: [Country]?
//    fileprivate let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if user.isCurrent {
//            searchController.searchResultsUpdater = self
//            searchController.dimsBackgroundDuringPresentation = false
//            searchController.delegate = self
//            definesPresentationContext = true
//            
            searchBar = TripSearchBar(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: view.frame.width, height: Constants.searchBarHeight)))
            searchBar?.delegate = self
            searchBar?.placeholder = LocalizableString.SearchCountries.localizedString
            
            tableView.tableHeaderView = searchBar
        }
        
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        activityIndicator.stopAnimating()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        view.endEditing(true)
    }
    
    // MARK: - Private methods
    
    fileprivate func rightUtilityButtons() -> [AnyObject] {
        if user.isCurrent {
            let rightUtilityButtons = NSMutableArray()
            rightUtilityButtons.sw_addUtilitySpecialDeleteButton(with: HexColor("2f9bd6")!, title: LocalizableString.Delete.localizedString)
            return rightUtilityButtons as [AnyObject]
        }
        return []
    }
    
    fileprivate func loadAllCountries() -> [Country] {
        var countries = [Country]()
        
        for code in Locale.isoRegionCodes {
            countries.append(Country.initWith(code))
        }
        
        return countries
    }
    
    fileprivate func filterContentForSearchText(searchText: String) {
        if searchText.numberOfCharactersWithoutSpaces() == 0 {
            filteredCountries = loadAllCountries()
        } else {
            filteredCountries = loadAllCountries().filter {
                $0.name.lowercased().contains(searchText.lowercased())
            }
        }
        
        tableView.reloadData()
    }
    
    fileprivate func deleteCountry(country: Country) {
        
        CountriesProvider.deleteCountry(country: country, for: user.objectId, completion: { [weak self] (result) in
            if let welf = self {
                
                switch(result) {
                case .success(let user):
                    
                    welf.user = user
                    welf.tableView.reloadData()
                    break
                case .failure(let error):
                    welf.showAlert(LocalizableString.Error.localizedString, message: error.localizedDescription, dismissTitle: LocalizableString.Ok.localizedString, completion: nil)
                    break
                default: break
                }
            }
        })
    }
    
    fileprivate func addCountry(country: Country) {
        CountriesProvider.addCountry(country: country, for: user.objectId, completion: { [weak self] (result) in
            if let welf = self {
                
                switch(result) {
                case .success(let user):
                    
                    welf.user = user
                    welf.tableView.reloadData()
                    
                    GoogleAnalyticsManager.userSelectCountry(country: country.name).sendEvent()
                    
                    break
                case .failure(let error):
                    welf.showAlert(LocalizableString.Error.localizedString, message: error.localizedDescription, dismissTitle: LocalizableString.Ok.localizedString, completion: nil)
                    break
                default: break
                }
            }
        })
    }
    
    fileprivate func isSearchBarActive() -> Bool {
        return searchBar?.isFirstResponder ?? false
    }
    
    fileprivate func hideSearchBar() {
        searchBar?.endEditing(true)
        searchBar?.showsCancelButton = false
        searchBar?.setNeedsDisplay()
        searchBar?.text = nil
        filterContentForSearchText(searchText: searchBar!.text!)
    }
}

// MARK: - UISearchControllerDelegate
extension TripsViewController: UISearchControllerDelegate {
    
    func didDismissSearchController(_ searchController: UISearchController) {
        filteredCountries = nil
        tableView.reloadData()
    }
}

// MARK: - UISearchBarDelegate
extension TripsViewController: UISearchBarDelegate {
    
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
            
            let country = user.countries[indexPath.row]
            deleteCountry(country: country)
        }
    }
}

// MARK: - UITableViewDelegate
extension TripsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let filteredCountries = filteredCountries {
            let country = filteredCountries[indexPath.row]
    
            if !user.countries.contains(country) {
                addCountry(country: country)
                
                hideSearchBar()
                
                self.filteredCountries = nil
                tableView.reloadData()
            }
        }
    }
}
