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
import Parse
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Helper.initialNavigationController().setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        firstEntranceLogicIfNeeds()
    }
    
    // MARK: - Private methods
    
    fileprivate func firstEntranceLogicIfNeeds() {
        if !FirstEntranceProvider.shared.isFirstEntrancePassed {
            
            switch FirstEntranceProvider.shared.currentStep {
            case .profile:
                // go to personal screen
                let profileController: PersonalTabsViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.profileControllerId)!
                Helper.initialNavigationController().pushViewController(profileController, animated: true)
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

        let alertView = UIAlertController(title: nil, message: LocalizableString.TakeImageFrom.localizedString, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        // library source
        alertView.addAction(UIAlertAction(title: LocalizableString.PhotoLibrary.localizedString, style: UIAlertActionStyle.default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            imagePicker.videoQuality = UIImagePickerControllerQualityType.typeHigh
            imagePicker.videoMaximumDuration = 14
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .photoLibrary
            imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: imagePicker.sourceType)!
            imagePicker.modalPresentationStyle = .popover
            self.present(imagePicker, animated: true, completion: nil)
        }))
        
        // camera source
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) == true {
            alertView.addAction(UIAlertAction(title: LocalizableString.TakeAPhotoVideo.localizedString, style: UIAlertActionStyle.default, handler: {
                (alert: UIAlertAction!) -> Void in
                imagePicker.videoMaximumDuration = 14
                imagePicker.sourceType = .camera
                imagePicker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
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
        
        Helper.initialNavigationController().pushViewController(createMomentController, animated: true)
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
        
        imagePicker.dismiss(animated: true, completion: nil)
        
        guard images.count > 0 else {
            print("No image selected")
            return
        }
        
        guard let instagramImage = images.first as? OLInstagramImage else {
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
            }
        }
    }
    
    func instagramImagePicker(_ imagePicker: OLInstagramImagePickerController!, shouldSelect image: OLInstagramImage!) -> Bool {
        return (imagePicker.selected.count < 1)
    }
}
