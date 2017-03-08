//
//  SettingsViewController.swift
//  Brizeo
//
//  Created by Roman Bayik on 1/27/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import CoreLocation
import Parse
import Branch
import FBSDKShareKit
import ChameleonFramework

class SettingsViewController: UIViewController {

    // MARK: - Types
    
    struct Constants {
        static let bigSectionHeightCoef: CGFloat = 74.0 / 1100.0
        static let normalSectionHeightCoef: CGFloat = 52.0 / 1100.0
        static let smallSectionHeightCoef: CGFloat = 26.0 / 1100.0
    }
    
    struct StoryboardIds {
        static let genderController = "GenderViewController"
    }
    
    enum Sections: Int {
        case currentLocation = 0
        case searchLocation
        case discovery
        case notifications
        case logout

        enum TypeOfHeight {
            case normal
            case small
            case big
            
            func height(tableViewHeight: CGFloat) -> CGFloat {
                var coef: CGFloat
                
                switch self {
                case .big:
                    coef = Constants.bigSectionHeightCoef
                case .normal:
                    coef = Constants.normalSectionHeightCoef
                case .small:
                    coef = Constants.smallSectionHeightCoef
                }
                return tableViewHeight * coef
            }
        }
    
        var rowsCount: Int {
            switch self {
            case .discovery,
                 .notifications:
                return 3
            default:
                return 1
            }
        }
        
        var title: String? {
            switch self {
            case .currentLocation:
                return "Current Location"
            case .searchLocation:
                return "Search for New Location"
            case .discovery:
                return "DISCOVERY SETTINGS"
            case .notifications:
                return "NOTIFICATIONS"
            default:
                return nil
            }
        }
        
        var type: TypeOfHeight {
            switch self {
            case .currentLocation,
                 .searchLocation:
                return .normal
            case .discovery,
                 .notifications:
                return .big
            default:
                return .small
            }
        }
        
        var headerViewId: String {
            switch type {
            case .big:
                return "SettingsBigHeaderView"
            default:
                return "SettingsNormalHeaderView" // for log out
            }
        }
        
        func cellHeightCoef(for row: Int) -> CGFloat {
            switch self {
            case .currentLocation:
                return 78.0 / 1120.0
            case .searchLocation,
                 .logout:
                return 76.0 / 1120.0
            case .discovery:
                if row == 0 { return 125.0 / 1120.0 }
                else if row == 1 { return 128.0 / 1120.0 }
                else { return 74.0 / 1120.0 }
            case .notifications:
                if row == 0 { return 77.0 / 1120.0 }
                else { return 70.0 / 1120.0 }
            }
        }
        
        func cellId(for row: Int) -> String {
            switch self {
            case .currentLocation:
                return "SettingsLocationCell"
            case .searchLocation:
                return "SettingsSearchLocationCell"
            case .discovery:
                if row == 0 { return "SettingsDistanceCell" }
                else if row == 1 { return "SettingsAgeCell"}
                else { return "SettingsGenderCell" }
            case .notifications:
                return "SettingsNotificationCell"
            case .logout:
                return "SettingsLogoutCell"
            }
        }
    }
    
    // MARK: - Properties
    
    @IBOutlet weak var tableView: UITableView!
    
    // basic objects
    var user: User! = UserProvider.shared.currentUser!
    var preferences: Preferences!
    
    // for location
    var currentLocationString = LocalizableString.Location.localizedString
    var searchLocationString = ""
    
    // for notifications
    var userNotificationSetting: [Bool] = [Bool]()
    
    // MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        registerHeaderViews()
        
        LocationManager.shared.updateLocation()
        // TODO: ask Josh about search location? It is changing every time we pass settings
        
        loadPreferences()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let result = LocationManager.shared.requestCurrentLocation { [weak self] (locationString, location) in
            
            if let locationString = locationString {
                if self != nil {
                    self?.currentLocationString = locationString
                    self?.tableView.reloadData()
                    
                    // update user
                    self?.user.location = location
                    UserProvider.updateUser(user: self!.user, completion: nil)
                }
            }
        }
        
        if let location = result.0 {
            self.currentLocationString = location
            self.tableView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        PreferencesProvider.updatePreferences(preferences: preferences, completion: nil)
    }
    
    // MARK: - Private methods
    
    fileprivate func presentErrorAlert(message: String?) {
        let alert = UIAlertController(title: LocalizableString.Error.localizedString, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: LocalizableString.TryAgain.localizedString, style: .default, handler: { (action) in
            self.loadPreferences()
        }))
        
        alert.addAction(UIAlertAction(title: LocalizableString.Dismiss.localizedString, style: .cancel, handler: { (action) in
            //TODO: switch to profile
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func loadPreferences() {
        
        PreferencesProvider.loadPreferences(for: user.objectId, fromCache: true) {  [weak self] (result) in
            if let welf = self {
                
                switch result {
                case .success(let value):
                    
                    welf.preferences = value
                    welf.getLocationString()
                    welf.tableView.reloadData()
                    
                    break
                case .failure(let error):
                    welf.presentErrorAlert(message: error.localizedDescription)
                    break
                default:
                    break
                }
            }
        }
    }
    
    fileprivate func registerHeaderViews() {
        tableView.register(UINib(nibName: SettingsBigHeaderView.nibName, bundle: nil), forHeaderFooterViewReuseIdentifier: SettingsBigHeaderView.nibName)
        tableView.register(UINib(nibName: SettingsNormalHeaderView.nibName, bundle: nil), forHeaderFooterViewReuseIdentifier: SettingsNormalHeaderView.nibName)
    }
    
    fileprivate func createSection(from number: Int) -> Sections? {
        guard let section = Sections(rawValue: number) else {
            assertionFailure("Error: No such section")
            return nil
        }
        
        return section
    }
    
    fileprivate func getLocationString() {
        if let preferences = preferences {
            let geocoder = CLGeocoder()
            
            if !preferences.hasLocation {
                return
            }
            
            geocoder.reverseGeocodeLocation(preferences.searchLocation!) {
                (placemarks, error) in
                if (placemarks != nil) {
                    let placemark = placemarks!.first
                    var locationName: String = ""
                    if let cityName = placemark?.locality {
                        locationName = locationName + cityName + ", "
                    }
                    
                    if let stateName = placemark?.administrativeArea {
                        locationName = locationName + stateName + ", "
                    }
                    
                    if let countryName = placemark?.country {
                        locationName = locationName + countryName
                    }
                    
                    if locationName.characters.count != 0 {
                        self.searchLocationString = locationName
                        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
                    }
                }
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension SettingsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = createSection(from: section) else {
            return 0
        }
        return section.rowsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let section = createSection(from: indexPath.section) else {
            return UITableViewCell()
        }
        let cellId = section.cellId(for: indexPath.row)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        switch section {
        case .currentLocation:
            let typeCell = cell as! SettingsLocationCell
            typeCell.titleLabel.text = currentLocationString
            return typeCell
        case .searchLocation:
            let typeCell = cell as! SettingsSearchLocationCell
            typeCell.delegate = self
            typeCell.textField.text = searchLocationString
            return typeCell
        case .discovery:
            if indexPath.row == 0 { // maximum distance
                let typeCell = cell as! SettingsRangeCell
                typeCell.delegate = self
                typeCell.distanceLabel?.text = LocalizableString.MaximumDistance.localizedString
                return typeCell
            } else if indexPath.row == 1 { // age range
                let typeCell = cell as! SettingsRangeCell
                typeCell.ageRangeLabel?.text = LocalizableString.AgeRange.localizedString.capitalized
                if let preferences = preferences {
                    typeCell.setupWithRange(preferences.ageLowerLimit, maxAgeRange: preferences.ageUpperLimit, distanceRange: preferences.maxSearchDistance)
                }

                typeCell.delegate = self
                return typeCell
            } else { // gender
                let typeCell = cell as! SettingsInvitationCell
                var genderString = ""
                
                if let preferences = preferences {
                    for gender in [Gender.Man, Gender.Woman, Gender.Couple] {
                        if preferences.genders.contains(gender) {
                            genderString += gender.title
                            genderString += " and"
                        }
                    }
                    
                    if genderString.characters.count > 0 {
                        let endIndex = genderString.index(genderString.endIndex, offsetBy: -4)
                        genderString = genderString.substring(to: endIndex)
                    }
                }
                
                typeCell.rightTextLabel.text = genderString
                typeCell.titleLabel.text = LocalizableString.Gender.localizedString
                
                return typeCell
            }
        case .notifications:
            let typeCell = cell as! SettingsNotificationCell
            var notificationValue = true
            
            if userNotificationSetting.count > 0 {
                notificationValue = userNotificationSetting[indexPath.row - 1]
            }
            
            typeCell.switcher.setOn(notificationValue, animated: false)
            typeCell.titleLabel.text = [LocalizableString.NewMatches.localizedString, LocalizableString.Messages.localizedString, LocalizableString.MomentsMatches.localizedString][indexPath.row]
            return cell
        case .logout:
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension SettingsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let section = createSection(from: indexPath.section) else {
            return 0.0
        }
        return section.cellHeightCoef(for: indexPath.row) * tableView.bounds.height
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let section = createSection(from: section) else {
            return 0.0
        }
        return section.type.height(tableViewHeight: tableView.bounds.height)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard let section = createSection(from: section), section == .logout else {
            return 0.0
        }
        
        return section.type.height(tableViewHeight: tableView.bounds.height)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let section = createSection(from: section) else {
            return nil
        }
        
        let headerView: SettingsHeaderView = tableView.dequeueReusableHeaderFooterView(withIdentifier: section.headerViewId)
        
        headerView.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: tableView.frame.width, height: section.type.height(tableViewHeight: tableView.frame.height)))
        headerView.titleLabel.text = section.title
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let section = createSection(from: section), section == .logout else {
            return nil
        }
        
        let footerView: SettingsNormalHeaderView = tableView.dequeueReusableHeaderFooterView(withIdentifier: SettingsNormalHeaderView.nibName)
        
        footerView.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: tableView.frame.width, height: section.type.height(tableViewHeight: tableView.frame.height)))
        footerView.titleLabel.text = nil
        return footerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let section = createSection(from: indexPath.section) else {
            return
        }
        
        switch section {
        case .logout:
            UserProvider.logout()
            Helper.goToInitialController(true)
            break
        case .discovery:
            if indexPath.row == 2 { // gender
                let genderController: GenderViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.genderController)!
                genderController.user = user
                genderController.preferences = preferences
                
                Helper.initialNavigationController().pushViewController(genderController, animated: true)
            }
            break
        default:
            break
        }
    }
}

// MARK: - SettingsRangeCellDelegate
extension SettingsViewController: SettingsRangeCellDelegate {
    
    func rangeCellDidSetDistanceValue(_ rangeCell: SettingsRangeCell, distanceValue: Int) {
        preferences?.maxSearchDistance = distanceValue
    }
    
    func rangeCellDidSetAgeValue(_ rangeCell: SettingsRangeCell, ageMinValue: Int, ageMaxValue: Int) {
        preferences?.ageLowerLimit = ageMinValue
        preferences?.ageUpperLimit = ageMaxValue
    }
}

// MARK: - SettingsSearchLocationCellDelegate
extension SettingsViewController: SettingsSearchLocationCellDelegate {
    
    func searchLocationCell(_ searchLocationCell: SettingsSearchLocationCell, didSelectText text: String) {
        searchLocationString = text
        LocationManager.shared.getLocationCoordinateForText(text) { (location) in
            
            if let location = location {
                self.preferences?.searchLocation = location
            }
        }
    }
    
    func searchLocationCell(_ searchLocationCell: SettingsSearchLocationCell, textSuggestionsForText text: String, completion: (([String]) -> Void)?) {
        
        LocationManager.shared.getLocationsForText(text) { (suggestions) in
            completion?(suggestions)
        }
    }
}
