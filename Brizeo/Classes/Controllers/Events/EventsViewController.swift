//
//  EventsViewController.swift
//  Brizeo
//
//  Created by Roman Bayik on 1/27/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import ChameleonFramework
import SDWebImage
import GooglePlacesAutocomplete
import CoreLocation
import SVProgressHUD

struct LocalizedString: ExpressibleByStringLiteral, Equatable {
    
    let value: String
    
    init(key: String) {
        self.value = NSLocalizedString(key, comment: "")
    }
    init(localized: String) {
        self.value = localized
    }
    init(stringLiteral value:String) {
        self.init(key: value)
    }
    init(extendedGraphemeClusterLiteral value: String) {
        self.init(key: value)
    }
    init(unicodeScalarLiteral value: String) {
        self.init(key: value)
    }
    
    static func ==(lhs:LocalizedString, rhs:LocalizedString) -> Bool {
        return lhs.value == rhs.value
    }
}

enum SortingFlag: LocalizedString {
    case popularity = "Popularity"
    case nearest = "Nearest"
    
    var localizedString: String {
        return self.rawValue.value
    }
    
    var APIPresentation: String {
        
        switch self {
        case .nearest:
            return "nearest"
        case .popularity:
            return "popular"
        }
    }
    
    init?(localizedString: String) {
        self.init(rawValue: LocalizedString(localized: localizedString))
    }
    
    static func allOptions() -> [SortingFlag] {
        
        return [
            .popularity,
            .nearest
        ]
    }
}

class EventsViewController: UIViewController {
    
    // MARK: - Types
    
    struct Constants {
        static let cornerRadius: CGFloat = 5.0
        static let borderWidth: CGFloat = 1.0
        static let cellHeight: CGFloat = 500.0
    }
    
    // MARK: - Properties
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var locationImageView: UIImageView! {
        didSet {
            locationImageView.image = locationImageView.image!.withRenderingMode(.alwaysTemplate)
        }
    }
    
    @IBOutlet weak var filterImageView: UIImageView! {
        didSet {
            filterImageView.image = filterImageView.image!.withRenderingMode(.alwaysTemplate)
        }
    }
    
    @IBOutlet weak var filterListButton: DropMenuButton! {
        didSet {
            filterListButton.backgroundColor = .clear
            filterListButton.layer.cornerRadius = Constants.cornerRadius
            filterListButton.layer.borderWidth = Constants.borderWidth
            filterListButton.layer.borderColor = HexColor("cccccc")!.cgColor
        }
    }
    
    @IBOutlet weak var locationTextField: UITextField! {
        didSet {
            locationTextField.layer.cornerRadius = Constants.cornerRadius
            locationTextField.layer.borderWidth = Constants.borderWidth
            locationTextField.layer.borderColor = HexColor("cccccc")!.cgColor
        }
    }
    
    var gpaViewController: GooglePlacesAutocomplete?
    var events: [Event]?
    var selectedflag = SortingFlag.popularity
    var selectedLocation: CLLocationCoordinate2D?
    var topRefresher: UIRefreshControl!
    
    // MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LocationManager.updateUserLocation()
        
        // set top refresher
        topRefresher = UIRefreshControl()
        topRefresher.addTarget(self, action: #selector(EventsViewController.refreshTableView), for: .valueChanged)
        tableView.addSubview(topRefresher)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if selectedLocation == nil {
            selectedLocation = LocationManager.shared.currentLocationCoordinates?.coordinate
            locationTextField.text = LocationManager.shared.currentLocationString
        }
        
        if events == nil || events?.count == 0 {
            loadEvents(true)
        }
    }
    
    // MARK: - Private methods
    
    fileprivate func loadEvents(_ animated: Bool) {
        
        if animated {
            showBlackLoader()
        }
        
        guard let selectedLocation = selectedLocation else {
            hideLoader()
            SVProgressHUD.showError(withStatus: "Please choose some location to see events.")
            return
        }
        
        EventsProvider.getEvents(sortingFlag: selectedflag, location: selectedLocation, completion: { (result) in
            switch (result) {
            case .success(let events):
                
                self.hideLoader()
                
                self.events = events
                self.tableView.reloadData()
                
                break
            case .failure(let error):
                SVProgressHUD.showError(withStatus: error.errorDescription)
                break
            default: break
            }
            
            self.topRefresher.endRefreshing()
        })
    }
    
    @objc fileprivate func refreshTableView() {
        loadEvents(false)
    }
    
    // MARK: - Actions
    
    @IBAction func onLocationButtonClicked(sender: UIButton) {
        
        if gpaViewController == nil {
            gpaViewController = GooglePlacesAutocomplete(
                apiKey: Configurations.GooglePlaces.key,
                placeType: .all
            )
            
            gpaViewController!.placeDelegate = self
        }
        
        let location = selectedLocation ?? LocationManager.shared.currentLocationCoordinates?.coordinate
        if let location = location {
            gpaViewController!.locationBias = LocationBias(latitude: location.latitude, longitude: location.longitude, radius: 20000)
        }
        
        ThemeManager.placeLogo(on: gpaViewController!.navigationItem)
        present(gpaViewController!, animated: true, completion: nil)
    }
    
    @IBAction func onFilterButtonClicked(sender: UIButton) {
        
        let alertController = UIAlertController(title: nil, message: LocalizableString.SelectEventFilter.localizedString, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        /*// add action for case "All"
         alertController.addAction(UIAlertAction(title: Constants.defaultFilterTitle, style: .default, handler: { (action) in
         
         self.selectedPassion = nil
         sender.setTitle(action.title, for: .normal)
         
         self.resetMoments()
         }))
         */
        
        let options = SortingFlag.allOptions()
        
        for option in options {
            
            alertController.addAction(UIAlertAction(title: option.rawValue.value, style: .default, handler: { (action) in
                
                if let flag = SortingFlag(localizedString: action.title!) {
                    self.selectedflag = flag
                    sender.setTitle(action.title, for: .normal)
                    
                    self.refreshTableView()
                }
            }))
        }
        
        alertController.addAction(UIAlertAction(title: LocalizableString.Cancel.localizedString, style: UIAlertActionStyle.cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource
extension EventsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: EventTableViewCell = tableView.dequeueCell(withIdentifier: EventTableViewCell.identifier, for: indexPath)
        let event = events![indexPath.row]

        cell.eventName.text = event.name
        cell.eventDescription.text = event.information
        cell.eventStartDate.text = event.startDateString
        cell.attendingLabel.text = "\(event.attendingsCount) \(LocalizableString.Attending.localizedString)"
        
        // preview image
        if let previewImageUrl = event.previewImageUrl {
            cell.eventImageView.sd_setImage(with: previewImageUrl)
        } else {
            cell.eventImageView.image = nil
        }
        
        // owner profile url
        if let profileURL = event.ownerUser.profileUrl {
            cell.eventOwnerImageView.sd_setImage(with: profileURL)
        } else {
            cell.eventOwnerImageView.image = nil
        }
        
        if event.hasLocation {
            LocationManager.shared.getMomentLocationStringForLocation(event.location!, event.objectId, completion: { [weak cell, weak self] (locationStr, eventId) in
                
                if cell != nil && self != nil {
                    guard let indexPath = tableView.indexPath(for: cell!) else {
                        return
                    }
                    
                    if let events = self!.events, events[indexPath.row].objectId == eventId {
                        cell!.distanceLabel.text = locationStr
                    }
                }
            })
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension EventsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.cellHeight
    }
}

// MARK: - GooglePlacesAutocompleteDelegate
extension EventsViewController: GooglePlacesAutocompleteDelegate {
    
    func placeSelected(_ place: Place) {
        
        locationTextField.text = place.description
        
        if place.location != nil {
            selectedLocation = place.location
            
            dismiss(animated: true) {
                self.gpaViewController?.reset()
            }
        } else {
            place.getDetails { [weak self] (result) in
                if let welf = self {
                    // set new values
                    welf.selectedLocation = CLLocationCoordinate2D(latitude: result.latitude, longitude: result.longitude)
                    
                    welf.dismiss(animated: true) {
                        welf.gpaViewController?.reset()
                    }
                }
            }
        }
    }
    
    func placeViewClosed() {
        gpaViewController?.view.endEditing(true)
        gpaViewController?.dismiss(animated: true, completion: nil)
    }
}
