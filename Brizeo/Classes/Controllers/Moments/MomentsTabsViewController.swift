//
//  MomentsTabsViewController.swift
//  Brizeo
//
//  Created by Roman Bayik on 1/31/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import MobileCoreServices
import CarbonKit
import GBHFacebookImagePicker
import InstagramImagePicker
import SDWebImage
import SVProgressHUD

protocol MomentsTabsViewControllerDelegate: class {
    func onCreateMoment()
}

let updateMomentsListNotification = "updateMomentsListNotification"

class MomentsTabsViewController: BasicViewController {

    // MARK: - Types
    
    struct Constants {
        static let titles = [
            LocalizableString.All.localizedString.capitalized,
            LocalizableString.MyMatches.localizedString.capitalized,
            LocalizableString.MyMoments.localizedString.capitalized
        ]
    }
    
    struct StoryboardIds {
        static let createMomentControllerId = "CreateMomentViewController"
        static let momentsControllerId = "MomentsViewController"
        static let profileControllerId = "PersonalTabsViewController"
        static let mediaControllerId = "MediaViewController"
        static let otherProfileControllerId = "OtherProfileViewController"
    }
    
    // MARK: - Properties
    
    var loadingView: UIView?
    var allMomentsController: MomentsViewController!
    var myMatchesMomentsController: MomentsViewController!
    var myMomentsController: MomentsViewController!
    
    // MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initContent()
        
        presentSharedContent()
        
        NotificationCenter.default.addObserver(self, selector: #selector(presentSharedContent), name: NSNotification.Name(rawValue: sharedValuesAreUpdated), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Helper.initialNavigationController().setNavigationBarHidden(true, animated: animated)
        
        LocalyticsProvider.userViewMomentsWall()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        firstEntranceLogicIfNeeds()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Private methods
    
    @objc fileprivate func presentSharedContent() {
        
        guard FirstEntranceProvider.shared.isFirstEntrancePassed == true else {
            return
        }
        
        // check whether we need to present user or moment
        if let userId = BranchProvider.userIdToPresent() {
            showUserProfile(with: userId, orMoment: nil)
        }
        
        if let momentId = BranchProvider.momentIdToPresent() {
            loadAndShowMoment(with: momentId)
        }
        
        BranchProvider.clearPresentData()
    }
    
    fileprivate func firstEntranceLogicIfNeeds() {
        if !FirstEntranceProvider.shared.isFirstEntrancePassed {
            
            switch FirstEntranceProvider.shared.currentStep {
            case .profile:
                // go to personal screen
                let profileController: PersonalTabsViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.profileControllerId)!
                navigationController?.pushViewController(profileController, animated: true)
                break
            case .moments:
                if !FirstEntranceProvider.shared.goingToCreateMoment {
                    
                    // show helper view
                    allMomentsController.hideHelpView(isHidden: false)
                }
                break
            }
        }
    }
    
    fileprivate func initContent() {
        guard let currentUser = UserProvider.shared.currentUser else {
            print("Error: no current user on moment tab")
            return
        }
        
        // load controller
        allMomentsController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.momentsControllerId)!
        allMomentsController.listType = MomentsListType.allMoments
        allMomentsController.parentDelegate = self
        
        myMatchesMomentsController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.momentsControllerId)!
        myMatchesMomentsController.listType = MomentsListType.myMatches(userId: currentUser.objectId)
        myMatchesMomentsController.parentDelegate = self
        
        myMomentsController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.momentsControllerId)!
        myMomentsController.listType = MomentsListType.myMoments(userId: currentUser.objectId)
        myMomentsController.parentDelegate = self
        
        let carbonTabSwipeNavigation = Helper.createCarbonController(with: Constants.titles, self)
        carbonTabSwipeNavigation.insert(intoRootViewController: self)
        carbonTabSwipeNavigation.pagesScrollView?.isScrollEnabled = false
    }
    
    fileprivate func showImageSourceAlertView() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self

        let alertView = UIAlertController(title: nil, message: LocalizableString.newMomentImageVideoSource.localizedString, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        // library photo source
        alertView.addAction(UIAlertAction(title: LocalizableString.PhotoLibrary.localizedString, style: UIAlertActionStyle.default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            imagePicker.videoQuality = UIImagePickerControllerQualityType.typeHigh
            imagePicker.sourceType = .photoLibrary
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.modalPresentationStyle = .popover
            self.present(imagePicker, animated: true, completion: nil)
        }))
        
        //library video source
        alertView.addAction(UIAlertAction(title: LocalizableString.VideoLibrary.localizedString, style: UIAlertActionStyle.default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            imagePicker.videoQuality = UIImagePickerControllerQualityType.typeHigh
            imagePicker.videoMaximumDuration = 14
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .photoLibrary
            imagePicker.mediaTypes = [kUTTypeMovie as String]
            imagePicker.modalPresentationStyle = .popover
            self.present(imagePicker, animated: true, completion: nil)
        }))
        
        // camera photo source
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) == true {
            alertView.addAction(UIAlertAction(title: LocalizableString.TakeAPhoto.localizedString, style: UIAlertActionStyle.default, handler: {
                (alert: UIAlertAction!) -> Void in
                imagePicker.sourceType = .camera
                imagePicker.cameraCaptureMode = .photo
                imagePicker.mediaTypes = [kUTTypeImage as String]
                imagePicker.modalPresentationStyle = .popover
                self.present(imagePicker, animated: true, completion: nil)
            }))
        }
        
        // camera video source
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) == true {
            alertView.addAction(UIAlertAction(title: LocalizableString.TakeAVideo.localizedString, style: UIAlertActionStyle.default, handler: {
                (alert: UIAlertAction!) -> Void in
                imagePicker.videoMaximumDuration = 14
                imagePicker.sourceType = .camera
                imagePicker.mediaTypes = [kUTTypeMovie as String]
                imagePicker.cameraCaptureMode = .video
                imagePicker.modalPresentationStyle = .popover
                self.present(imagePicker, animated: true, completion: nil)
            }))
        }
        
        // facebook source
        alertView.addAction(UIAlertAction(title: LocalizableString.TakeAPhotoFromFacebook.localizedString, style: UIAlertActionStyle.default, handler: {
            (alert: UIAlertAction!) -> Void in
            let picker = GBHFacebookImagePicker()
            picker.presentFacebookAlbumImagePicker(from: self, delegate: self)
        }))
        
        // instagram source
        alertView.addAction(UIAlertAction(title: LocalizableString.TakeAPhotoFromInstagram.localizedString, style: UIAlertActionStyle.default, handler: {
            (alert: UIAlertAction!) -> Void in
            guard let imagePicker = OLInstagramImagePickerController(clientId: Configurations.Instagram.clientId, secret: Configurations.Instagram.clientSecret, redirectURI: Configurations.Instagram.redirectURL) else {
                print("Can't create instagram controller")
                return
            }
            
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
        }))
        
        alertView.addAction(UIAlertAction(title: LocalizableString.Cancel.localizedString, style: UIAlertActionStyle.cancel, handler: { (action) in
            // first entrance logic
            if FirstEntranceProvider.shared.isFirstEntrancePassed == false && FirstEntranceProvider.shared.currentStep == .moments {
                // show helper view
                self.allMomentsController.hideHelpView(isHidden: false)
            }
        }))
        
        present(alertView, animated: true, completion: nil)
    }
    
    fileprivate func createNewMoment(with image: UIImage?, videoURL: URL?) {
        FirstEntranceProvider.shared.goingToCreateMoment = true
        
        let createMomentController: CreateMomentViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.createMomentControllerId)!
        createMomentController.image = image
        createMomentController.videoURL = videoURL
        
        if let videoURL = videoURL {
            // generate thumbnail from video url
            let thumbnailImage = Helper.generateThumbnail(from: videoURL)
            createMomentController.thumbnailImage = thumbnailImage
        }
        
        navigationController?.pushViewController(createMomentController, animated: true)
    }
    
    fileprivate func presentErrorAlert(momentId: String, message: String?) {
        let alert = UIAlertController(title: LocalizableString.Error.localizedString, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: LocalizableString.TryAgain.localizedString, style: .default, handler: { (action) in
            self.loadAndShowMoment(with: momentId)
        }))
        
        alert.addAction(UIAlertAction(title: LocalizableString.Dismiss.localizedString, style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func loadAndShowMoment(with momentId: String) {
        showBlackLoader()
        
        MomentsProvider.getMoment(with: momentId) { (result) in
            self.hideLoader()
            
            switch (result) {
            case .success(let moment):
                self.show(moment: moment)
                break
            case .failure(_):
                self.presentErrorAlert(momentId: momentId, message: LocalizableString.LoadMomentError.localizedString)
                break
            default:
                break
            }
        }
    }
    
    fileprivate func show(moment: Moment) {
        let mediaController: MediaViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.mediaControllerId)!
        mediaController.isSharingEnabled = true
        mediaController.moment = moment
        
        Helper.currentTabNavigationController()?.pushViewController(mediaController, animated: true)
    }
    
    fileprivate func showUserProfile(with userId: String?, orMoment moment: Moment?) {
        let userIdentifier = userId ?? moment?.ownerId ?? "-1"
        
        if userIdentifier == UserProvider.shared.currentUser!.objectId { // don't show my current profile because there is no sense in it
        } else {
            let otherPersonProfileController: OtherProfileViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.otherProfileControllerId)!
            otherPersonProfileController.user = moment?.user
            otherPersonProfileController.userId = userIdentifier
            
            Helper.currentTabNavigationController()?.pushViewController(otherPersonProfileController, animated: true)
        }
    }
}

extension MomentsTabsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            let fixedImage = pickedImage.fixedOrientation()
            createNewMoment(with: fixedImage, videoURL: nil)
            return
        }
        
        if let videoURL = info[UIImagePickerControllerMediaURL] as? URL {
            createNewMoment(with: nil, videoURL: videoURL)
            return
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - CarbonTabSwipeNavigationDelegate
extension MomentsTabsViewController: CarbonTabSwipeNavigationDelegate {
    
    func carbonTabSwipeNavigation(_ carbonTabSwipeNavigation: CarbonTabSwipeNavigation, viewControllerAt index: UInt) -> UIViewController {
        Helper.placeLogo(on: navigationController?.tabBarController?.navigationController?.navigationItem)
        if index == 0 {
            return allMomentsController
        } else if index == 1 {
            return myMatchesMomentsController
        } else {
            return myMomentsController
        }
    }
}

// MARK: - MomentsTabsViewControllerDelegate
extension MomentsTabsViewController: MomentsTabsViewControllerDelegate {
    
    func onCreateMoment() {
        showImageSourceAlertView()
    }
}

// MARK: - GBHFacebookImagePickerDelegate
extension MomentsTabsViewController: GBHFacebookImagePickerDelegate {
    
    func facebookImagePicker(imagePicker: UIViewController, imageModel: GBHFacebookImage) {
        print("Image URL : \(imageModel.fullSizeUrl), Image Id: \(imageModel.imageId)")
        
        if let pickedImage = imageModel.image {
            createNewMoment(with: pickedImage, videoURL: nil)
        }
    }
    
    func facebookImagePicker(imagePicker: UIViewController, didFailWithError error: Error?) {
        print("Cancelled Facebook Album picker with error")
        print(error.debugDescription)
    }
    
    func facebookImagePicker(didCancelled imagePicker: UIViewController) {
        print("Cancelled Facebook Album picker")
    }
    
    func facebookImagePickerDismissed() {
        print("Picker dismissed")
    }
}

// MARK: - OLInstagramImagePickerControllerDelegate
extension MomentsTabsViewController: OLInstagramImagePickerControllerDelegate {
    
    func instagramImagePickerDidCancelPickingImages(_ imagePicker: OLInstagramImagePickerController!) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func instagramImagePicker(_ imagePicker: OLInstagramImagePickerController!, didFailWithError error: Error!) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func instagramImagePicker(_ imagePicker: OLInstagramImagePickerController!, didSelect image: OLInstagramImage!) {
    }
    
    func instagramImagePicker(_ imagePicker: OLInstagramImagePickerController!, didFinishPickingImages images: [Any]!) {
        
        guard images.count > 0 else {
            imagePicker.dismiss(animated: true, completion: nil)
            print("No image selected")
            return
        }
        
        guard let instagramImage = images.first as? OLInstagramImage else {
            imagePicker.dismiss(animated: true, completion: nil)
            return
        }
        
        // load image
        SVProgressHUD.show()
        SDWebImageManager.shared().downloadImage(with: instagramImage.fullURL, options: SDWebImageOptions.highPriority, progress: { (currentBytes, totalBytes) in
        }) { (image, error, cacheType, finished, url) in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                
                if image != nil {
                    self.createNewMoment(with: image, videoURL: nil)
                }
                
                imagePicker.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func instagramImagePicker(_ imagePicker: OLInstagramImagePickerController!, shouldSelect image: OLInstagramImage!) -> Bool {
        return (imagePicker.selected.count < 1)
    }
}
