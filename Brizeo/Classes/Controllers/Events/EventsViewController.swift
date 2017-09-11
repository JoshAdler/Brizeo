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
    case earliest = "Date"
    
    var localizedString: String {
        return self.rawValue.value
    }
    
    var APIPresentation: String {
        
        switch self {
        case .nearest:
            return "nearest"
        case .popularity:
            return "popular"
        case .earliest:
            return "earliest"
        }
    }
    
    init?(localizedString: String) {
        self.init(rawValue: LocalizedString(localized: localizedString))
    }
    
    static func allOptions() -> [SortingFlag] {
        
        return [
            .earliest,
            .nearest,
            .popularity
        ]
    }
}

enum EventsContentType {
    case all
    case matches
}

class EventsViewController: UIViewController {
    
    // MARK: - Types
    
    struct Constants {
        static let cornerRadius: CGFloat = 5.0
        static let borderWidth: CGFloat = 1.0
        static let cellHeight: CGFloat = 337.0
    }
    
    struct StoryboardIds {
        static let otherProfileControllerId = "OtherProfileViewController"
        static let profileControllerId = "PersonalTabsViewController"
        static let likesControllerId = "LikesViewController"
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
    
    weak var parentController: EventTabsViewController?
    var gpaViewController: GooglePlacesAutocomplete?
    var events: [Event]?
    var selectedflag = SortingFlag.earliest//SortingFlag.nearest
    var selectedLocation: CLLocationCoordinate2D?
    var topRefresher: UIRefreshControl!
    var type = EventsContentType.all
    var shouldReload = false
    var shouldHideLocation = false
    
    // MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 300
        
        // set top refresher
        topRefresher = UIRefreshControl()
        topRefresher.addTarget(self, action: #selector(EventsViewController.refreshTableView), for: .valueChanged)
        tableView.addSubview(topRefresher)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if shouldHideLocation {
            
            locationImageView.isHidden = true
            locationTextField.isHidden = true
        }
        //            if self.events == nil || self.events?.count == 0 || self.shouldReload {
        //                self.loadEvents(true)
        //            }
        //        } else {
        
        if selectedLocation == nil {
            
            // set current location
            let currentLocation = LocationManager.shared.requestCurrentLocation({ (locationStr, locationCoordinates) in
                
                self.selectedLocation = locationCoordinates?.coordinate
                self.locationTextField.text = locationStr
                
                if self.events == nil || self.events?.count == 0 || self.shouldReload {
                    self.loadEvents(true)
                } else {
                    self.hideLoader()
                }
            })
            
            if currentLocation.0 != nil && currentLocation.1 != nil {
                
                selectedLocation = currentLocation.1!.coordinate
                locationTextField.text = currentLocation.0
                
                if events == nil || events?.count == 0 || shouldReload {
                    loadEvents(true)
                }
            } else {
                showBlackLoader()
            }
            //            }
        } else {
            if self.events == nil || self.events?.count == 0 || self.shouldReload {
                self.loadEvents(true)
            }
        }
    }
    
    // MARK: - Private methods
    
    fileprivate func loadEvents(_ animated: Bool) {
        
        shouldReload = false
        
        if animated {
            showBlackLoader()
        }
        
        if !shouldHideLocation && self.selectedLocation == nil {
            hideLoader()
            SVProgressHUD.showError(withStatus: "Please choose some location to see events.")
            return
        }
        
        let selectedLocation = self.selectedLocation ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        
        print("Location: \(selectedLocation.longitude), \(selectedLocation.latitude)")
        
        EventsProvider.getEvents(contentType: type, sortingFlag: selectedflag, location: selectedLocation, completion: { (result) in
            switch (result) {
            case .success(let events):
                
                self.hideLoader()
                
                self.events = events
                self.tableView.reloadData()
                
                // hide/show popup arrow if needs
                if let firstEvent = events.first {
                    let contentURL = firstEvent.ownerUser.profileUrl
                    self.parentController?.popupView?.setContentURL(contentURL)
                }
                
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
    
    fileprivate func showUserProfile(for user: User) {
        
        if user.objectId == UserProvider.shared.currentUser!.objectId { // show my profile
            
            let profileController: PersonalTabsViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.profileControllerId)!

            Helper.currentTabNavigationController()?.pushViewController(profileController, animated: true)
        } else {
        
            let otherPersonProfileController: OtherProfileViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.otherProfileControllerId)!
            
            otherPersonProfileController.user = user
            otherPersonProfileController.userId = user.objectId
            
            Helper.currentTabNavigationController()?.pushViewController(otherPersonProfileController, animated: true)
        }
    }
    
    fileprivate func openEvent(_ event: Event) {
        
        let url = URL(string: "fb://event?id=\(event.facebookId)")
        
        // open facebook event on FB app
        if UIApplication.shared.canOpenURL(url!) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url!)
            }
        } else {
            let safeURL = URL(string: "https://www.facebook.com/events/\(event.facebookId)")
            
            if UIApplication.shared.canOpenURL(safeURL!) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(safeURL!, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(safeURL!)
                }
            } else {
                SVProgressHUD.showError(withStatus: LocalizableString.FacebookEventURLFails.localizedString)
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func onLocationButtonClicked(sender: UIButton) {
        
        if shouldHideLocation {
            return
        }
        
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
            gpaViewController?.reset()
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
                    
                    //self.refreshTableView()
                    self.loadEvents(true)
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

        cell.delegate = self
        cell.eventName.text = event.name
        cell.eventDescription.text = event.information
        cell.eventStartDate.text = event.startDateString
        cell.attendingLabel.text = "\(event.attendingsCount) \(LocalizableString.Attending.localizedString)"
        
        if let distance = event.distance {
            cell.distanceLabel.text = "\(Int(distance.rounded(.toNearestOrAwayFromZero))) miles away"
        } else {
            cell.distanceLabel.text = "several miles away"
        }
        
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
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension EventsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension//Constants.cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let event = events![indexPath.row]
        openEvent(event)
    }
}

// MARK: - EventTableViewCellDelegate
extension EventsViewController: EventTableViewCellDelegate {
    
    func eventCell(cell: EventTableViewCell, didClickedOnProfile button: UIButton) {
        
        guard let indexPath = tableView.indexPath(for: cell) else {
            print("No index path for cell")
            return
        }
        
        guard let event = events?[indexPath.row] else {
            print("No event for this index path")
            return
        }
        
        showUserProfile(for: event.ownerUser)
    }
    
    func eventCell(cell: EventTableViewCell, didClickedOnAttendings button: UIButton) {
        
        guard let indexPath = tableView.indexPath(for: cell) else {
            print("No index path for cell")
            return
        }
        
        guard let event = events?[indexPath.row] else {
            print("No event for this index path")
            return
        }
        
        let likersController: LikesViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.likesControllerId)!
        likersController.event = event
        
        Helper.currentTabNavigationController()?.pushViewController(likersController, animated: true)
    }
}

// MARK: - GooglePlacesAutocompleteDelegate
extension EventsViewController: GooglePlacesAutocompleteDelegate {
    
    func placeSelected(_ place: Place?) {
        
        guard let place = place else {
            return
        }
        
        locationTextField.text = place.description
        
        if place.location != nil {
            selectedLocation = place.location
            
            shouldReload = true
            
            dismiss(animated: true) {
                self.gpaViewController?.reset()
            }
        } else {
            place.getDetails { [weak self] (result) in
                if let welf = self {
                    // set new values
                    welf.selectedLocation = CLLocationCoordinate2D(latitude: result.latitude, longitude: result.longitude)
                    
                    welf.shouldReload = true
                    
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
