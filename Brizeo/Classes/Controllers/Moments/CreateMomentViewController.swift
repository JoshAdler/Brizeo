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

class CreateMomentViewController: UIViewController {

    // MARK: - Types
    
    struct Constants {
        static let switcherHeightCoef: CGFloat = 80.0 / 43.0
        static let switcherWidthCoef: CGFloat = 80.0 / 750.0
        static let placeholderText = LocalizableString.TypeHere.localizedString
        static let placeholderTextColor = HexColor("b2b2b2")
        static let defaultTextColor = UIColor.black
    }
    
    // MARK: - Properties
    
    @IBOutlet weak var momentImageView: UIImageView!
    @IBOutlet weak var captionTextView: UITextView!
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
    
    var image: UIImage?
    var user: User?
    var selectedInterest: Interest?
    var interests: [Interest]?
    var autocompleteLocationsResults: [MKMapItem]?
    var selectedLocation: CLLocationCoordinate2D?
    var suggestions: [String]?

    // MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // apply image/location
        momentImageView.image = image
        selectedLocation = LocationManager.shared.currentLocationCoordinates?.coordinate
        
        // set placeholder to text view
        showPlaceholder()
        
        // setup autocomplete text field
        setupLocationTextField()
        
        resizeViewWhenKeyboardAppears = false
        
        fetchInterests()
    }
    
    // MARK: - Private methods
    
    fileprivate func fetchInterests() {
        showBlackLoader()
        InterestProvider.retrieveAllInterests { (result) in
            DispatchQueue.main.async {
                self.hideLoader()
                
                switch result {
                case .success(let interests):
                    self.interests = interests.sorted(by: {$0.displayOrder < $1.displayOrder})
                    self.initFilterButton()
                case .failure(let error):
                    self.showAlert(LocalizableString.Error.localizedString, message: error, dismissTitle: LocalizableString.Dismiss.localizedString, completion: nil)
                }
            }
        }
    }
    
    fileprivate func showPlaceholder() {
        captionTextView.text = Constants.placeholderText
        captionTextView.textColor = Constants.placeholderTextColor
        captionTextView.selectedTextRange = captionTextView.textRange(from: captionTextView.beginningOfDocument, to: captionTextView.beginningOfDocument)
    }
    
    fileprivate func initFilterButton() {
        guard interests != nil && interests!.count > 0 else {
            print("No interests")
            return
        }
        
        selectedInterest = interests!.filter({ $0.DisplayName == "Travel" }).first ?? interests?.first!
        
        // set default value
        interestButton.setTitle(selectedInterest?.DisplayName, for: .normal)
        interestButton.isEnabled = true
    }
    
    fileprivate func setupLocationTextField() {
        addLocationTextField.dataSourceDelegate = self
        addLocationTextField.rowHeight = 50.0
        addLocationTextField.dropDownTableViewHeight = 150
        addLocationTextField.animationStyle = .slide
        addLocationTextField.text = LocationManager.shared.currentLocationString ?? LocalizableString.Location.localizedString
    }
    
    fileprivate func captionText() -> String? {
        if captionTextView.text == Constants.placeholderText && captionTextView.text == Constants.placeholderText {
            return nil
        } else {
            return captionTextView.text
        }
    }
    
    // MARK: - Actions
    
    @IBAction func onBackButtonClicked(_ sender: UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onFilterButtonClicked(_ sender: UIButton) {
        guard interests != nil && interests!.count > 0 else {
            print("No interests")
            return
        }
        
        let alertController = UIAlertController(title: nil, message: LocalizableString.SelectInterest.localizedString, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        for interest in interests! {
            alertController.addAction(UIAlertAction(title: interest.DisplayName, style: .default, handler: { (action) in
                
                self.selectedInterest = self.interests!.filter({ $0.DisplayName == action.title }).first
                self.interestButton.setTitle(action.title, for: .normal)
            }))
        }
        
        alertController.addAction(UIAlertAction(title: LocalizableString.Cancel.localizedString, style: UIAlertActionStyle.cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func onPostButtonClicked(_ sender: UIBarButtonItem) {
        view.endEditing(true)
        
        guard let text = captionText(), text.numberOfCharactersWithoutSpaces() > 0 else {
            let noDescriptionView: NoDescriptionView = NoDescriptionView.loadFromNib()
            noDescriptionView.present(on: Helper.initialNavigationController().view)
            return
        }
        
        
        
        
        /*
        if captionTextView.text.numberOfCharactersWithoutSpaces() != 0 && captionTextView.text != LocalizableString.WriteACapture.localizedString {
            
            showBlackLoader()
            MomentsProvider.createMomentWithImage(image, andDescription: captionTextView.text, forUser: user, completion: { (result) in
                
                self.hideLoader()
                switch result {
                case .success(let value):
                    GoogleAnalyticsManager.userCreateNewMoment.sendEvent()
                    //TODO: go next
                    //self.navigationCoordinator?.performTransition(Transition.momentUploadFinished(moment: value))
                    break
                case .failure(let error):
                    self.showAlert(LocalizableString.Error.localizedString, message: error, dismissTitle: LocalizableString.Ok.localizedString, completion: nil)
                    break
                }
            })
        } else {
            showAlert("", message: LocalizableString.MomentsMustHaveADescription.localizedString, dismissTitle: LocalizableString.Ok.localizedString, completion: {
                
                self.captionTextView.becomeFirstResponder()
            })
        }*/
    }
}

// MARK: - UITextViewDelegate
extension CreateMomentViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let currentText = textView.text as NSString?
        let updatedText = currentText?.replacingCharacters(in: range, with: text)
        
        if let updatedText = updatedText, !updatedText.isEmpty  {
            if textView.textColor == Constants.placeholderTextColor && !text.isEmpty {
                textView.text = nil
                textView.textColor = Constants.defaultTextColor
            }
        } else {
            textView.text = Constants.placeholderText
            textView.textColor = Constants.placeholderTextColor
            
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            
            return false
        }
        return true
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if self.view.window != nil {
            if textView.textColor == Constants.placeholderTextColor {
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            }
        }
    }
}

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

