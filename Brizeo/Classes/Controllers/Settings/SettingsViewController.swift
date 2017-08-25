//
//  SettingsViewController.swift
//  Brizeo
//
//  Created by Roman Bayik on 1/27/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import CoreLocation
import FBSDKShareKit
import ChameleonFramework
import GooglePlacesAutocomplete
import SVProgressHUD

let searchLocationChangedNotification = "searchLocationChangedNotification"
let searchNationalityChangedNotification = "searchNationalityChangedNotification"

class SettingsViewController: UIViewController {

    // MARK: - Types
    
    struct Constants {
        static let bigSectionHeight: CGFloat = 54.0
        static let normalSectionHeight: CGFloat = 54.0
        static let smallSectionHeight: CGFloat = 15.0
    }
    
    struct StoryboardIds {
        static let genderController = "GenderViewController"
        static let nationalityController = "OptionsNationalityViewController"
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
            
            var height: CGFloat {
                
                switch self {
                case .big: return Constants.bigSectionHeight
                case .normal: return Constants.normalSectionHeight
                case .small: return Constants.smallSectionHeight
                }
            }
        }
    
        var rowsCount: Int {
            switch self {
            case .notifications:
                return 3
            case .discovery:
                return 4
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
        
        var fontColor: UIColor {
            switch self {
            case .searchLocation:
                return HexColor("1f4ba5")!
            default: return HexColor("5f5f5f")!
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
        
        func cellHeight(for row: Int) -> CGFloat {
            switch self {
            case .currentLocation:
                return 53.0
            case .searchLocation,
                 .logout:
                return 52.0
            case .discovery:
                if row == 0 { return 108.0 }
                else if row == 1 { return 109.0 }
                else { return 71.0 }
            case .notifications:
                if row == 0 { return 55.0 }
                else { return 53.0 }
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
    var user: User!
    var preferences: Preferences!
    var isSelected = false
    var isSearchLocationChanged = false
    
    // for location
    var currentLocationString = LocalizableString.Location.localizedString
    var searchLocationString = ""
    var gpaViewController: GooglePlacesAutocomplete?
    
    // for university
    var universityViewController: GooglePlacesAutocomplete?
    
    fileprivate var isSearchingLocation = false
    
    // MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        user = UserProvider.shared.currentUser!
        
        registerHeaderViews()
        LocationManager.shared.updateLocation()
        loadPreferences()
        
        // add observer for gender
        NotificationCenter.default.addObserver(self, selector: #selector(searchGenderWasChanged(notification:)), name: NSNotification.Name(rawValue: searchGenderWasChangedNotification), object: nil)
        
        // add observer for nationality
        NotificationCenter.default.addObserver(self, selector: #selector(searchNationalityWasChanged(notification:)), name: NSNotification.Name(rawValue: searchNationalityChangedNotification), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        user = UserProvider.shared.currentUser!
        
        let result = LocationManager.shared.requestCurrentLocation { [weak self] (locationString, location) in
            
            if let locationString = locationString {
                if self != nil {
                    self?.currentLocationString = locationString
                    self?.tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
                    
                    // update user
                    self?.user.location = location
                    UserProvider.updateUser(user: self!.user, completion: nil)
                }
            }
        }
        
        if let location = result.0 {
            self.currentLocationString = location
            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
        }
        
        // RB Comment: unneccessary code
//        // reload gender
//        tableView.reloadRows(at: [IndexPath(row: 2, section: 2)], with: .automatic)
        
        // reload nationality
        tableView.reloadRows(at: [IndexPath(row: 2, section: 2)], with: .automatic)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Public methods
    
    func searchGenderWasChanged(notification: NSNotification) {
        
        isSearchLocationChanged = true
    }
    
    func searchNationalityWasChanged(notification: NSNotification) {
        
        isSearchLocationChanged = true
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
                
                // place current location
                searchLocationString = currentLocationString
                preferences.searchLocation = LocationManager.shared.currentLocationCoordinates
                
                // update tableview
                tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
                
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
                
                if let preferences = preferences {
                    typeCell.setupWithRange(preferences.ageLowerLimit, maxAgeRange: preferences.ageUpperLimit, distanceRange: preferences.maxSearchDistance)
                }
                
                typeCell.delegate = self
                return typeCell
            } else if indexPath.row == 1 { // age range
                let typeCell = cell as! SettingsRangeCell
                typeCell.ageRangeLabel?.text = LocalizableString.AgeRange.localizedString.capitalized
                
                if let preferences = preferences {
                    typeCell.setupWithRange(preferences.ageLowerLimit, maxAgeRange: preferences.ageUpperLimit, distanceRange: preferences.maxSearchDistance)
                }

                typeCell.delegate = self
                return typeCell
//            } else if indexPath.row == 2 { // gender
//                let typeCell = cell as! SettingsInvitationCell
//                var genderString = ""
//                
//                if let preferences = preferences {
//                    for gender in [Gender.Man, Gender.Woman, Gender.Couple] {
//                        if preferences.genders.contains(gender) {
//                            genderString += gender.titlePlural
//                            genderString += " and "
//                        }
//                    }
//                    
//                    if genderString.characters.count > 0 {
//                        let endIndex = genderString.index(genderString.endIndex, offsetBy: -4)
//                        genderString = genderString.substring(to: endIndex)
//                    }
//                }
//                
//                typeCell.rightTextLabel.text = genderString
//                typeCell.titleLabel.text = LocalizableString.Gender.localizedString
//                
//                return typeCell
            } else if indexPath.row == 2 { // nationality
                
                let typeCell = cell as! SettingsInvitationCell
                
                if let nationalityCode = preferences.searchNationality {
                    
                    let country = Country.initWith(nationalityCode)
                    typeCell.rightTextLabel.text = country.name.capitalized
                } else {
                    typeCell.rightTextLabel.text = "All"
                }
                
                typeCell.titleLabel.text = LocalizableString.Nationality.localizedString
                
                return typeCell
            } else { // university
                
                let typeCell = cell as! SettingsInvitationCell
                
                if let searchUniversity = preferences.searchUniversity {
                    typeCell.rightTextLabel.text = searchUniversity
                } else {
                    typeCell.rightTextLabel.text = LocalizableString.Choose.localizedString
                }
                
                typeCell.titleLabel.text = LocalizableString.University.localizedString
                
                return typeCell
            }
        case .notifications:
            let typeCell = cell as! SettingsNotificationCell
            let notificationInfo = preferences.getNotificationInfo(for: indexPath.row)
            
            typeCell.delegate = self
            typeCell.switcher.setOn(notificationInfo.1, animated: true)
            typeCell.titleLabel.text = notificationInfo.0
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
        return section.cellHeight(for: indexPath.row)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let section = createSection(from: section) else {
            return 0.0
        }
        return section.type.height
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard let section = createSection(from: section), section == .logout else {
            return 0.0
        }
        
        return section.type.height
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let section = createSection(from: section) else {
            return nil
        }
        
        let headerView: SettingsHeaderView = tableView.dequeueReusableHeaderFooterView(withIdentifier: section.headerViewId)
        
        headerView.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: tableView.frame.width, height: section.type.height))
        headerView.titleLabel.text = section.title
        headerView.titleLabel.textColor = section.fontColor
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let section = createSection(from: section), section == .logout else {
            return nil
        }
        
        let footerView: SettingsNormalHeaderView = tableView.dequeueReusableHeaderFooterView(withIdentifier: SettingsNormalHeaderView.nibName)
        
        footerView.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: tableView.frame.width, height: section.type.height))
        footerView.titleLabel.text = nil
        return footerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let section = createSection(from: indexPath.section) else {
            return
        }
        
        switch section {
        case .searchLocation:
            if indexPath.row == 0 {
                
                isSearchingLocation = true
                
                if gpaViewController == nil {
                    gpaViewController = GooglePlacesAutocomplete(
                        apiKey: Configurations.GooglePlaces.key,
                        placeType: .cities//.address
                    )
                    
                    gpaViewController!.placeDelegate = self
                }
                
                let location = preferences.searchLocation?.coordinate ?? LocationManager.shared.currentLocationCoordinates?.coordinate
                if let location = location {
                    gpaViewController!.locationBias = LocationBias(latitude: location.latitude, longitude: location.longitude, radius: 20000)
                    gpaViewController!.reset()
                }
                
                ThemeManager.placeLogo(on: gpaViewController!.navigationItem)
                present(gpaViewController!, animated: true, completion: nil)
            }
            break
        case .logout:
            UserProvider.logout()
            Helper.goToInitialController(true)
            break
        case .discovery:
            //            if indexPath.row == 2 { // gender
            //
            //                let genderController: GenderViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.genderController)!
            //                genderController.user = user
            //                genderController.preferences = preferences
            //
            //                navigationController?.pushViewController(genderController, animated: true)
            //            } else
            if indexPath.row == 2 { // nationality
                
                let optionsController: OptionsNationalityViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.nationalityController)!
                optionsController.user = user
                optionsController.preferences = preferences
                optionsController.source = .search
                
                navigationController?.pushViewController(optionsController, animated: true)
            } else if indexPath.row == 3 { // university
                
                isSearchingLocation = false
                
                if universityViewController == nil {
                    universityViewController = GooglePlacesAutocomplete(
                        apiKey: Configurations.GooglePlaces.key,
                        placeType: .university
                    )
                    
                    universityViewController!.placeDelegate = self
                    universityViewController!.isAutocomplete = false
                }
                
                universityViewController!.reset()
                
                ThemeManager.placeLogo(on: universityViewController!.navigationItem)
                present(universityViewController!, animated: true, completion: nil)
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
        
        isSearchLocationChanged = true
        
        // notify about changes
        Helper.sendNotification(with: searchLocationChangedNotification, object: nil, dict: nil)
    }
    
    func rangeCellDidSetAgeValue(_ rangeCell: SettingsRangeCell, ageMinValue: Int, ageMaxValue: Int) {
        preferences?.ageLowerLimit = ageMinValue
        preferences?.ageUpperLimit = ageMaxValue
        
        isSearchLocationChanged = true
        
        // notify about changes
        Helper.sendNotification(with: searchLocationChangedNotification, object: nil, dict: nil)
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

// MARK: - SettingsNotificationCellDelegate
extension SettingsViewController: SettingsNotificationCellDelegate {
    
    func notificationCell(cell: SettingsNotificationCell, didChangedValueTo value: Bool) {
        
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        preferences.setNotificationValue(value: value, for: indexPath.row)
        PreferencesProvider.updatePreferences(preferences: preferences, completion: nil)
    }
}

// MARK: - GooglePlacesAutocompleteDelegate
extension SettingsViewController: GooglePlacesAutocompleteDelegate {
    
    func placeSelected(_ place: Place) {
        
        if isSearchingLocation {
            
            searchLocationString = place.description
            
            showBlackLoader()
            
            place.getDetails { [weak self] (result) in
                if let welf = self {
                    // set new values
                    welf.preferences.searchLocation = CLLocation(latitude: result.latitude, longitude: result.longitude)
                    
                    welf.isSearchLocationChanged = true
                    
                    // update preferences
                    PreferencesProvider.updatePreferences(preferences: welf.preferences, completion: { (result) in
                        switch(result) {
                        case .success(_):
                            
                            // notify about changes
                            Helper.sendNotification(with: searchLocationChangedNotification, object: nil, dict: nil)
                            
                            welf.hideLoader()
                            welf.tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
                            break
                        case .failure(let error):
                            SVProgressHUD.showError(withStatus: error.localizedDescription)
                            break
                        default: break
                        }
                        
                        welf.dismiss(animated: true) {
                            welf.gpaViewController?.reset()
                            welf.isSearchingLocation = false
                        }
                    })
                }
            }
        } else { // university
            
            showBlackLoader()
            preferences.searchUniversity = place.desc
            
            isSearchLocationChanged = true
            
            // update preferences
            PreferencesProvider.updatePreferences(preferences: preferences, completion: { (result) in
                
                switch(result) {
                case .success(_):
                    
                    // notify about changes
                    Helper.sendNotification(with: searchLocationChangedNotification, object: nil, dict: nil)
                    
                    self.hideLoader()
                    self.tableView.reloadRows(at: [IndexPath(row: 3, section: 2)], with: .automatic)
                    break
                case .failure(let error):
                    SVProgressHUD.showError(withStatus: error.localizedDescription)
                    break
                default: break
                }
                
                self.dismiss(animated: true) {
                    self.universityViewController?.reset()
                    self.isSearchingLocation = false
                }
            })
        }
    }
    
    func placeViewClosed() {
        
        var controller: UIViewController?
        
        if isSearchingLocation {
            controller = gpaViewController
        } else {
            controller = universityViewController
        }
        
        controller?.view.endEditing(true)
        controller?.dismiss(animated: true, completion: nil)
        
        isSearchingLocation = false
    }
}
