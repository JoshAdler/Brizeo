//
//  CreateMomentViewController.swift
//  Brizeo
//
//  Created by Roman Bayik on 1/31/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import ChameleonFramework
import MapKit
import ZTDropDownTextField
import SVProgressHUD
import GooglePlacesAutocomplete
import KMPlaceholderTextView

class CreateMomentViewController: UIViewController {

    // MARK: - Types
    
    struct Constants {
        static let switcherHeightCoef: CGFloat = 80.0 / 43.0
        static let switcherWidthCoef: CGFloat = 80.0 / 750.0
        static let placeholderText = LocalizableString.TypeHere.localizedString
        static let placeholderTextColor = HexColor("b2b2b2")!
    }
    
    // MARK: - Properties
    
    @IBOutlet weak var rightNavigationButton: UIBarButtonItem!
    @IBOutlet weak var momentImageView: UIImageView!
    @IBOutlet weak var captionTextView: KMPlaceholderTextView! {
        didSet {
            captionTextView.placeholder = Constants.placeholderText
            captionTextView.placeholderColor = Constants.placeholderTextColor
        }
    }
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var addLocationTextField: ZTDropDownTextField! {
        didSet {
            addLocationTextField.placeholder = LocalizableString.AddLocation.localizedString
        }
    }
    @IBOutlet weak var interestButton: UIButton! {
        didSet {
            interestButton.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            interestButton.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            interestButton.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        }
    }
    
    @IBOutlet weak var switcher: UISwitch! {
        didSet {
            let scaleX = (Constants.switcherWidthCoef * UIScreen.main.bounds.width) / switcher.bounds.width
            let scaleY = (Constants.switcherWidthCoef * UIScreen.main.bounds.width) / Constants.switcherHeightCoef / switcher.bounds.height
            switcher.transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
        }
    }
    @IBOutlet weak var passionTitleLabel: UILabel! {
        didSet {
            passionTitleLabel.text = LocalizableString.SelectPassion.localizedString
        }
    }
    @IBOutlet weak var visibilityLabel: UILabel! {
        didSet {
            visibilityLabel.text = LocalizableString.ViewablebyAll.localizedString
        }
    }
    
    var thumbnailImage: UIImage?
    var videoURL: URL?
    var image: UIImage?
    var selectedPassion: Passion?
    var moment: Moment?
    var passions: [Passion]?
    var autocompleteLocationsResults: [MKMapItem]?
    var selectedLocation: CLLocationCoordinate2D?
    var suggestions: [String]?
    var gpaViewController: GooglePlacesAutocomplete?

    // MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if moment == nil {
            
            // apply image/location
            momentImageView.image = image ?? thumbnailImage
            selectedLocation = LocationManager.shared.currentLocationCoordinates?.coordinate
            
            // setup autocomplete text field
            setupLocationTextField()
        }
        
        fetchPassions()
        
        // hide keyboard on click anywhere
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Private methods
    
    fileprivate func applyMoment() {
        // rename post => update
        rightNavigationButton.title = LocalizableString.Update.localizedString
        
        // set image
        momentImageView.sd_setImage(with: moment!.imageUrl)
        
        // set capture
        captionTextView.text = moment!.capture
        
        // viewable to All
        switcher.setOn(moment!.viewableByAll, animated: false)
        
        // passion
        selectedPassion = passions!.filter({ $0.objectId == moment!.passionId }).first
        interestButton.setTitle(selectedPassion?.displayName, for: .normal)
        
        // location
        if let location = moment!.location {
            selectedLocation = location.coordinate
            LocationManager.shared.getLocationStringForLocation(location) { [weak self] (title) in
                if let welf = self {
                    welf.addLocationTextField.text = title
                }
            }
        }
    }
    
    fileprivate func fetchPassions() {
        showBlackLoader()
        
        PassionsProvider.shared.retrieveAllPassions(true) { [weak self] (result) in
            if let welf = self {
                DispatchQueue.main.async {
                    welf.hideLoader()
                    
                    switch result {
                    case .success(let passions):
                        welf.passions = passions
                        welf.initFilterButton()
                        
                        if welf.moment != nil {
                            welf.applyMoment()
                        }
                    case .failure(let error):
                        welf.presentErrorAlert(message: error.localizedDescription)
                    default:
                        break
                    }
                }
            }
        }
    }
    
    fileprivate func presentErrorAlert(message: String?) {
        let alert = UIAlertController(title: LocalizableString.Error.localizedString, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: LocalizableString.TryAgain.localizedString, style: .default, handler: { (action) in
            self.fetchPassions()
        }))
        
        alert.addAction(UIAlertAction(title: LocalizableString.Dismiss.localizedString, style: .cancel, handler: { (action) in
            _ = self.navigationController?.popViewController(animated: true)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func initFilterButton() {
        guard passions != nil && passions!.count > 0 else {
            print("No passions")
            fetchPassions()
            return
        }
        
        selectedPassion = passions!.filter({ $0.displayName == "Travel" }).first ?? passions!.first!
        
        // set default value
        interestButton.setTitle(selectedPassion?.displayName, for: .normal)
        interestButton.isEnabled = true
    }
    
    fileprivate func setupLocationTextField() {
        addLocationTextField.dataSourceDelegate = self
        addLocationTextField.rowHeight = 50.0
        addLocationTextField.dropDownTableViewHeight = 150
        addLocationTextField.animationStyle = .slide
        addLocationTextField.text = LocationManager.shared.currentLocationString ?? LocalizableString.Location.localizedString
    }
    
    fileprivate func createMoment() {
        showBlackLoader()
        
        let moment = Moment()
        
        moment.capture = captionTextView.text
        moment.passionId = selectedPassion?.objectId
        moment.viewableByAll = switcher.isOn
        moment.ownerId = UserProvider.shared.currentUser!.objectId
        moment.locationLongitude = selectedLocation?.longitude
        moment.locationLatitude = selectedLocation?.latitude
        moment.image = image
        moment.videoURL = videoURL
        moment.thumbnailImage = thumbnailImage
        
        MomentsProvider.create(new: moment) { (result) in
            switch(result) {
            case .success(_):
                SVProgressHUD.showSuccess(withStatus: LocalizableString.NewMomentCreated.localizedString)
                
                FirstEntranceProvider.shared.isFirstEntrancePassed = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    
                    // set defaults
                    Helper.sendNotification(with: updateMomentsListNotification, object: nil, dict: nil)
                    
                    // go back
                    _ = self.navigationController?.popViewController(animated: true)
                }
                
                break
            case .failure(let error):
                SVProgressHUD.showError(withStatus: error.localizedDescription)
                break
            default:
                break
            }
        }
    }

    // MARK: - Actions
    
    @IBAction func onBackButtonClicked(_ sender: UIBarButtonItem) {
        FirstEntranceProvider.shared.goingToCreateMoment = false
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onFilterButtonClicked(_ sender: UIButton) {
        guard passions != nil && passions!.count > 0 else {
            print("No interests")
            return
        }
        
        let alertController = UIAlertController(title: nil, message: LocalizableString.SelectInterest.localizedString, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        for passion in passions! {
            alertController.addAction(UIAlertAction(title: passion.displayName, style: .default, handler: { (action) in
                
                self.selectedPassion = self.passions!.filter({ $0.displayName == action.title }).first
                self.interestButton.setTitle(action.title, for: .normal)
            }))
        }
        
        alertController.addAction(UIAlertAction(title: LocalizableString.Cancel.localizedString, style: UIAlertActionStyle.cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func onPostButtonClicked(_ sender: UIBarButtonItem) {
        view.endEditing(true)
        
        guard let text = captionTextView.text, text.numberOfCharactersWithoutSpaces() > 0 else {
            let noDescriptionView: NoDescriptionView = NoDescriptionView.loadFromNib()
            noDescriptionView.present(on: Helper.initialNavigationController().view)
            return
        }
        
        createMoment()
    }
    
    @IBAction func onLocationClicked(sender: UIButton) {
        
        if gpaViewController == nil {
            gpaViewController = GooglePlacesAutocomplete(
                apiKey: Configurations.GooglePlaces.key,
                placeType: .establishment
            )
            
            gpaViewController!.placeDelegate = self
        }
        
        ThemeManager.placeLogo(on: gpaViewController!.navigationItem)
        present(gpaViewController!, animated: true, completion: nil)
    }
}

// MARK: - UITextViewDelegate
extension CreateMomentViewController: UITextViewDelegate {}

// MARK: - UITextFieldDelegate
extension CreateMomentViewController: UITextFieldDelegate {

    @IBAction func textFieldDidChange(_ textField: UITextField) {
        guard (textField.text?.numberOfCharactersWithoutSpaces() ?? 0) >= 3 else {
            suggestions = nil
            autocompleteLocationsResults = nil
            
            return
        }
        
        LocationManager.requestLocation(with: textField.text, completionHandler: { [weak self] (response) in
            if self != nil {
                guard response != nil else {
                    print("No response")
                    return
                }
                
                // save result
                self!.autocompleteLocationsResults = response!.mapItems
                self!.suggestions = [String]()
                
                for item in response!.mapItems {
                    self!.suggestions!.append(item.placemark.asString())
                }
                
                self!.addLocationTextField.dropDownTableView.reloadData()
            }
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - ZTDropDownTextFieldDataSourceDelegate
extension CreateMomentViewController: ZTDropDownTextFieldDataSourceDelegate {
    
    func dropDownTextField(_ dropDownTextField: ZTDropDownTextField, numberOfRowsInSection section: Int) -> Int {
        return suggestions?.count ?? 0
    }
    
    func dropDownTextField(_ dropDownTextField: ZTDropDownTextField, didSelectRowAtIndexPath indexPath: IndexPath) {
        guard let selectedMark = self.autocompleteLocationsResults?[indexPath.row] else {
            print("No selected mark")
            return
        }
        
        // select mark
        addLocationTextField.text = selectedMark.placemark.asString()
        selectedLocation = selectedMark.placemark.coordinate
        
        // end editing
        addLocationTextField.resignFirstResponder()
        
        // clear previous results
        autocompleteLocationsResults = nil
        suggestions = nil
    }
    
    func dropDownTextField(_ dropDownTextField: ZTDropDownTextField, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        let cell = dropDownTextField.dropDownTableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .default, reuseIdentifier: "Cell")
        
        cell.textLabel!.text = suggestions?[indexPath.row] ?? ""
        cell.textLabel!.font = addLocationTextField.font!
        cell.textLabel!.textColor = UIColor.darkGray
        
        return cell
    }
}

// MARK: - GooglePlacesAutocompleteDelegate
extension CreateMomentViewController: GooglePlacesAutocompleteDelegate {
    
    func placeSelected(_ place: Place) {
        
        addLocationTextField.text = place.description
        
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
    
    func placeViewClosed() {
        gpaViewController?.view.endEditing(true)
        gpaViewController?.dismiss(animated: true, completion: nil)
    }
}
