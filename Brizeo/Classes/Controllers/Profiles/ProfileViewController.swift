//
//  ProfileViewController.swift
//  Brizeo
//
//  Created by Roman Bayik on 1/30/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import CarbonKit
import AlamofireImage
import MobileCoreServices
import AVFoundation
import SDWebImage

protocol ProfileViewControllerDelegate: class {
    func shouldShowDetails()
}

class ProfileViewController: UIViewController {

    // MARK: - Types
    
    enum MediaSource {
        case photo
        case video
        case photoVideo
        case photoVideoDelete
    }
    
    struct Constants {
        static let numberOfPhotosInCollectionView = 4
        static let photoWidthCoef: CGFloat = 261.0 / 750.0
    }
    
    struct StoryboardIds {
        static let imageCell = "ProfileImageCollectionViewCell"
        static let mediaController = "MediaViewController"
    }
    
    // MARK: - Properties
    
    @IBOutlet fileprivate weak var profileImageView: UIImageView!
    @IBOutlet fileprivate weak var imagesCollectionView: UICollectionView!
    @IBOutlet fileprivate weak var bottomView: UIView!
    
    weak var delegate: ProfileViewControllerDelegate?
    var index: Int = 0
    var user: User = User.test()
    var indexOfMediaToChange = -1
    
    var bottomSpaceHeight: CGFloat {
        return bottomView.frame.height
    }
    
//    @IBOutlet fileprivate weak var bottomViewTopConstraint: NSLayoutConstraint!
//    @IBOutlet fileprivate weak var bottomViewButton: UIButton!
//    @IBOutlet fileprivate weak var bottomViewContainerView: UIView!
//    @IBOutlet fileprivate weak var takePictureContainerView: UIView!
//    @IBOutlet fileprivate weak var takePictureVisualEffectView: UIVisualEffectView!
//    @IBOutlet weak var likeDislikeContainerView: UIView!
//    @IBOutlet weak var userAgeLabel: UILabel!
//    @IBOutlet weak var userActivityLabel: UILabel!
//    @IBOutlet weak var dislikeButton: UIButton!
//    @IBOutlet weak var likeButton: UIButton!
//    @IBOutlet weak var reportButton: UIButton!
//    @IBOutlet weak var likeDislikeContainerViewHeightConstraint: NSLayoutConstraint!
//    @IBOutlet weak var imagesCollectionViewHeightConstraint: NSLayoutConstraint!
    
    
//
//    var delegate : UserMatchesActionDelegate?
//    fileprivate var shouldGotoMomentView: Bool = false
//    //Analytics
//    fileprivate var userDidTapMoreInformation = false
//    fileprivate var userDidTapMomments = false
//    fileprivate var bottomViewIsVisible = false
//    fileprivate var userMediaCurrentIndex = 0
//    fileprivate var userMatchesViewController : UserMatchesViewController?
//    fileprivate var userTabs: [LocalizableString] {
//        guard let user = user else {
//            return []
//        }
//        
//        if User.userIsCurrentUser(user) {
//            return [.About, .Matches, .MyMap]
//        } else {
//            return [.About, .Moments, .Map]
//        }
//    }
    
    // MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        user = User.test()
        profileImageView.sd_setImage(with: user.profileImageUrl)
        
//        if user == nil {
//            user = User.current()!
//        } else if !User.userIsCurrentUser(user!) {
////            showLikeButtons(false, animated: false)
////            if user!.uploadedMedia.count < 2 {
////                imagesCollectionViewHeightConstraint.constant = 0
////            }
//            MatchesProvider.didUser(User.current()!, alreadyVoteOnUser: user!, completion: { (result) in
//                
//                switch (result) {
//                case .success(let voted):
//                    
//                    if (!voted) {
//                        self.showLikeButtons(true, animated: false)
//                    }
//                    break
//                case .failure(let error):
//                    
//                    self.showAlert(LocalizableString.Error.localizedString, message: error, dismissTitle: LocalizableString.Ok.localizedString, completion: nil)
//                    break
//                }
//            })
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //userMatchesViewController?.viewWillAppear(animated)
    }
    
    // MARK: - Actions
    
    //    @IBAction func addImageButtonTapped(_ sender: UIButton) {
    //
    //        userMediaCurrentIndex = 0
    //        takePhotoOrVideo()
    //    }
    
    @IBAction func onBottomButtonClicked(_ sender: UIButton) {
        delegate?.shouldShowDetails()
    }
    
    @IBAction func onPhotoButtonClicked(_ sender: UIButton) {
        indexOfMediaToChange = 0 // profile media
        showNewMediaAlert(with: .photo)
    }
    
    @IBAction func onVideoButtonClicked(_ sender: UIButton) {
        indexOfMediaToChange = 0 // profile media
        showNewMediaAlert(with: .video)
    }
    
    @IBAction func onProfilePhotoClicked(_ sender: UIButton) {
        let mediaController: MediaViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.mediaController)!
        mediaController.initialIndex = 0
        mediaController.media = user.uploadedMedia
        
        navigationController?.pushViewController(mediaController, animated: true)
    }
    
    // MARK: - Public methods
    
    func updateWithUser(_ user: User) {
        self.user = user
        setupUI()
    }
    
    func setupUI() {
        return
//        if let user = user {
//            if User.userIsCurrentUser(user) {
//                takePictureVisualEffectView.isHidden = true
//                likeDislikeContainerView.isHidden = true
//            } else {
//                
//                takePictureContainerView.isHidden = true
//                takePictureVisualEffectView.isHidden = false
//                likeDislikeContainerView.isHidden = false
//                
//                var distanceString = ""
//                if let currentLocation = User.current()!.location, let distance = user.getDistanceString(currentLocation) {
//                    distanceString = distance
//                }
//                let activityString = user.getActivityString()
//                if activityString?.numberOfCharactersWithoutSpaces() > 0 {
//                    distanceString += String(format: "%@%@", distanceString.characters.count > 0 ? " · " : "", user.getActivityString() ?? "")
//                }
//                
//                userAgeLabel.text = String(format: LocalizableString.YearsOld.localizedString, arguments: [user.age])
//                userActivityLabel.text = distanceString
//            }
//            
//            var items = [String]()
//            for tab in userTabs {
//                items.append(tab.localizedString.uppercased())
//            }
//            let color = UIColor(colorLiteralRed: 0.0/255.0, green: 104/255.0, blue: 217/255.0, alpha: 1.0)
//            let width = UIScreen.main.bounds.width
//            let carbonTabSwipeNavigation = CarbonTabSwipeNavigation(items: items, delegate: self)
//            carbonTabSwipeNavigation.insert(intoRootViewController: self, andTargetView: bottomViewContainerView)
//            carbonTabSwipeNavigation.view.backgroundColor = UIColor.clear
//            carbonTabSwipeNavigation.setIndicatorHeight(0.0)
//            carbonTabSwipeNavigation.setIndicatorHeight(4.0)
//            carbonTabSwipeNavigation.setIndicatorColor(color)
//            carbonTabSwipeNavigation.setTabExtraWidth(10)
//            for i in 0 ... items.count - 1 {
//                carbonTabSwipeNavigation.carbonSegmentedControl?.setWidth(width / CGFloat(items.count), forSegmentAt: i)
//            }
//            
//            carbonTabSwipeNavigation.setNormalColor(UIColor.black, font: UIFont(name: "HelveticaNeue-Light", size: 17.0)!)
//            carbonTabSwipeNavigation.setSelectedColor(UIColor.color(11.0, green: 106.0, blue: 216.0), font: UIFont(name: "HelveticaNeue-Light", size: 17.0)!)
//            carbonTabSwipeNavigation.toolbar.barTintColor = UIColor.white
//            reloadUserImages()
//        }
    }
    
    func reloadUserImages() {
//        if let media = user?.uploadedMedia {
//            if let firstImage = media.first, let imageUrl = ProfileMediaTypePreviewUrl(firstImage), let url = URL(string: imageUrl) {
//                profileImageView.af_setImage(withURL: url)
//            }
//            imagesCollectionView.reloadData()
//        }
    }
    
    // MARK: - Private methods
    
    fileprivate func showNewMediaAlert(with source: MediaSource) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        // action for media from library
        let libraryMedia = UIAlertAction(title: LocalizableString.Library.localizedString, style: UIAlertActionStyle.default, handler: {
            (alert: UIAlertAction!) -> Void in
            imagePicker.allowsEditing = true
            imagePicker.videoQuality = UIImagePickerControllerQualityType.typeHigh
            imagePicker.videoMaximumDuration = 10
            imagePicker.sourceType = .photoLibrary
            imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: imagePicker.sourceType)!
            
            switch source {
            case .photo:
                if imagePicker.mediaTypes.contains(kUTTypeImage as String) {
                    imagePicker.mediaTypes = [kUTTypeImage as String]
                }
                break
            case .video:
                if imagePicker.mediaTypes.contains(kUTTypeMovie as String) {
                    imagePicker.mediaTypes = [kUTTypeMovie as String]
                }
            default:
                break
            }
            
            imagePicker.modalPresentationStyle = .popover
            self.present(imagePicker, animated: true, completion: nil)
        })
        
        // action for media from camera
        let cameraMedia = UIAlertAction(title: LocalizableString.Camera.localizedString, style: UIAlertActionStyle.default, handler: {
            (alert: UIAlertAction!) -> Void in
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .camera
            imagePicker.videoQuality = UIImagePickerControllerQualityType.typeMedium
            imagePicker.showsCameraControls = true
            
            switch source {
            case .photo:
                imagePicker.cameraCaptureMode = .photo
                imagePicker.mediaTypes = [kUTTypeImage as String]
                break
            case .video:
                imagePicker.cameraCaptureMode = .video
                imagePicker.mediaTypes = [kUTTypeMovie as String]
            default:
                break
            }
            
            imagePicker.modalPresentationStyle = .popover
            self.present(imagePicker, animated: true, completion: nil)
        })
        
        // action for media from camera
        let deleteMedia = UIAlertAction(title: LocalizableString.Delete.localizedString, style: UIAlertActionStyle.default, handler: {
            (alert: UIAlertAction!) -> Void in
            guard self.indexOfMediaToChange > 0 && self.indexOfMediaToChange < self.user.uploadedImages.count else {
                assertionFailure("Bad index for deleting a media")
                return
            }
   
            //TODO: uncomment when will be ready
            /*
            self.user.uploadedImages.remove(at: self.indexOfMediaToChange)
            self.imagesCollectionView.deleteItems(at: [IndexPath(row: self.indexOfMediaToChange, section: 0)])
            self.indexOfMediaToChange = -1
 */
            
        })
        
        let cancelAction = UIAlertAction(title: LocalizableString.Cancel.localizedString, style: UIAlertActionStyle.cancel, handler: nil)
        
        var alertTitle: String?
        
        switch source {
        case .photo:
            alertTitle = LocalizableString.TakeAPhoto.localizedString
            break
        case .video:
            alertTitle = LocalizableString.TakeAVideo.localizedString
            break
        case .photoVideo:
            alertTitle = LocalizableString.TakeAMedia.localizedString
            break
        case .photoVideoDelete:
            alertTitle = LocalizableString.EditOrDelete.localizedString
        }
        
        let alertView = UIAlertController(title: nil, message: alertTitle, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        alertView.addAction(libraryMedia)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) == true {
            alertView.addAction(cameraMedia)
        }
        
        if source == .photoVideoDelete {
            alertView.addAction(deleteMedia)
        }
        
        alertView.addAction(cancelAction)
        
        present(alertView, animated: true, completion: nil)
    }
}

// MARK: - UICollectionViewDataSource
extension ProfileViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Constants.numberOfPhotosInCollectionView
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StoryboardIds.imageCell, for: indexPath) as! ProfileImageCollectionViewCell
        
        cell.delegate = self
        cell.imageView.image = #imageLiteral(resourceName: "ic_add_photo_plus")
        cell.isDeleteButtonHidden = false

        //TODO: enable you to edit pictures
        if indexPath.row < user.uploadedImages.count {
            let imageURL = user.uploadedImages[indexPath.row]
            cell.imageView.sd_setImage(with: imageURL)
        } else {
            cell.imageView.image = #imageLiteral(resourceName: "ic_add_photo_plus")
        }
        
//        if let media = user?.uploadedMedia , (indexPath as NSIndexPath).section < media.count {
//            let item = media[(indexPath as NSIndexPath).section]
//            if User.userIsCurrentUser(self.user!) {
//                cell.imageView.image = #imageLiteral(resourceName: "ic_add_photo_plus")
//            }
//            if let imageUrl = ProfileMediaTypePreviewUrl(item), let url = URL(string: imageUrl) {
//                cell.imageView.af_setImage(withURL: url)
//                cell.isDeleteButtonHidden = User.userIsCurrentUser(self.user!)
//            }
//        }
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension ProfileViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row < user.uploadedImages.count { // show media
            let mediaController: MediaViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.mediaController)!
            mediaController.initialIndex = indexPath.row
            mediaController.media = user.uploadedMedia
            
            navigationController?.pushViewController(mediaController, animated: true)
        } else { // plus button
            showNewMediaAlert(with: .photoVideo)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout {
extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width * Constants.photoWidthCoef
        let height = collectionView.frame.height
        
        return CGSize(width: width, height: height)
    }
}


// MARK: - UIImagePickerControllerDelegate {
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
//        if User.current()?.uploadImages?.count == 1 {
//            self.shouldGotoMomentView = true
//        }
//        
        picker.dismiss(animated: true, completion: nil)
//        if let chosenImage: UIImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
//            if let imageData = UIImageJPEGRepresentation(chosenImage, 0.8) {
////                let imageFile = ImageDataToProfileMediaType(imageData)
////                user?.addMediaAtIndex(imageFile, index: userMediaCurrentIndex)
////                setImageAtIndex(chosenImage, index: userMediaCurrentIndex)
//            }
//        } else {
//            if let url = info[UIImagePickerControllerMediaURL] as? URL, let videoData = try? Data(contentsOf: url) {
//                
//                let asset = AVURLAsset(url: url, options: nil)
//                let generator = AVAssetImageGenerator(asset: asset)
//                generator.appliesPreferredTrackTransform = true
//                let time = CMTimeMakeWithSeconds(0, 15)
//                let size = CGSize(width: 200, height: 200)
//                generator.maximumSize = size
//                
//                do {
//                    let imgRef = try generator.copyCGImage(at: time, actualTime: nil)
//                    let thumb = UIImage(cgImage: imgRef)
//                    let imageData = UIImageJPEGRepresentation(thumb, 0.8)!
//                    
//                    let file = VideoDataToProfileMediaType(videoData, thumbImageData: imageData)
//                    user?.addMediaAtIndex(file, index: userMediaCurrentIndex)
//                    setImageAtIndex(thumb, index: userMediaCurrentIndex)
//                } catch {
//                }
//            }
//        }
//
//        
//        User.saveParseUser { (result) in
//            
//        }
//        userMediaCurrentIndex = 0
//        
//        let interestCount = User.current()?.interests.count
//        print(interestCount)
//        print(User.current()?.uploadImages?.count)
//        print(shouldGotoMomentView)
//        if interestCount > 0 && self.shouldGotoMomentView && User.current()?.uploadImages?.count > 1{
//            self.tabBarController?.selectedIndex = 2
//            self.shouldGotoMomentView = false
//        }
        
        indexOfMediaToChange = -1
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        
        indexOfMediaToChange = -1
    }
}

// MARK: - ProfileImageCollectionViewCellDelegate {
extension ProfileViewController: ProfileImageCollectionViewCellDelegate {
    
    func profileImageCollectionView(_ cell: ProfileImageCollectionViewCell, onDeleteButtonClicked button: UIButton) {
        
        guard let indexPath = imagesCollectionView.indexPath(for: cell) else {
            return
        }
        
        indexOfMediaToChange = indexPath.row
        showNewMediaAlert(with: .photoVideoDelete)
    }
}
    
//    init(user: User?) {
//        
//        self.user = user
//        super.init(nibName: String(describing: ProfileViewController.self), bundle: nil)
//        
//        tabBarItem.title = LocalizableString.Profile.localizedString
//        tabBarItem.image = BrizeoImage.ProfileGrey.image.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
//        tabBarItem.selectedImage = BrizeoImage.ProfileBlue.image
//    }

    
//    @IBAction func reportUser(_ sender: UIButton) {
//        
//        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//        let reportAction = UIAlertAction(title: LocalizableString.Report.localizedString, style: .default, handler: { alert in
//            self.showBlackLoader()
//            UserProvider.reportUser(self.user!, user: User.current()!, completion: { (result) in
//                
//                self.hideLoader()
//                switch result {
//                    
//                case .success(_):
//                    self.showAlert("", message: LocalizableString.UserHadBeenReported.localizedString, dismissTitle: LocalizableString.Ok.localizedString, completion: nil)
//                    break
//                case .failure(let error):
//                    self.showAlert(LocalizableString.Error.localizedString, message: error, dismissTitle: LocalizableString.Ok.localizedString, completion: nil)
//                }
//            })
//        })
//        alertVC.addAction(reportAction)
//        let cancelAction = UIAlertAction(title: LocalizableString.Cancel.localizedString, style: .cancel, handler: nil)
//        alertVC.addAction(cancelAction)
//        
//        present(alertVC, animated: true, completion: nil)
//    }
//    
//    func showLikeButtons(_ show: Bool, animated: Bool) {
//        
//        likeDislikeContainerViewHeightConstraint.constant = show ? 228.0 : 80.0
//        UIView.animate(withDuration: animated ? 0.4 : 0.0, delay: 0.0, options: UIViewAnimationOptions(), animations: {
//            
//            self.dislikeButton.alpha = show ? 1.0 : 0.0
//            self.likeButton.alpha = show ? 1.0 : 0.0
//            self.view.layoutIfNeeded()
//            
//        }) { (finished) in
//        }
//    }
//    
//    @IBAction func dislikeButtonTapped(_ sender: UIButton) {
//        
//        userLikeDislikeMatch()
//        showBlackLoader()
//        MatchesProvider.user(User.current()!, didPassUser: user!, completion: { (result) in
//            
//            self.hideLoader()
//            switch (result) {
//            case .success:
//                
//                self.delegate?.userDidLikeDislikeUser(self, loadNext: true)
//                self.navigationCoordinator?.performTransition(Transition.didLikeDislikeUser)
//                self.showLikeButtons(false, animated: true)
//                self.resetUserActions()
//                break
//            case .failure(let error):
//                
//                self.showAlert(LocalizableString.Error.localizedString, message: error, dismissTitle: LocalizableString.Ok.localizedString, completion: nil)
//                break
//            }
//        })
//    }
//    
//    @IBAction func likeButtonTapped(_ sender: UIButton) {
//        
//        userLikeDislikeMatch()
//        showBlackLoader()
//        MatchesProvider.user(User.current()!, didLikeUser: user!, completion: { (result) in
//            
//            self.hideLoader()
//            switch (result) {
//            case .success(let isMatch):
//                
//                if (isMatch) {
//                    self.navigationCoordinator?.performTransition(Transition.didFindMatch(user: self.user!, userMatchesActionDelegate: self.delegate))
//                } else {
//                    self.delegate?.userDidLikeDislikeUser(self, loadNext: true)
//                }
//                
//                self.showLikeButtons(false, animated: true)
//                self.resetUserActions()
//                break
//            case .failure(let error):
//                
//                self.showAlert(LocalizableString.Error.localizedString, message: error, dismissTitle: LocalizableString.Ok.localizedString, completion: nil)
//                break
//            }
//        })
//    }
//    
//    func userLikeDislikeMatch() {
//        
//        if userDidTapMoreInformation {
//            
//            GoogleAnalyticsManager.userHitLikeDislikeAfterSeeingMoreInformation.sendEvent()
//        } else if userDidTapMomments {
//            
//            GoogleAnalyticsManager.userHitLikeDislikeAfterSeeingMoments.sendEvent()
//        } else {
//            
//            GoogleAnalyticsManager.userHitLikeDislikeAfterSeeingProfilePicture.sendEvent()
//        }
//    }

//    func resetUserActions() {
//        
//        userDidTapMoreInformation = false
//        userDidTapMomments = false
//    }

//    @IBAction func profileImageTapped(_ sender: UIButton) {
//        
//        navigationCoordinator?.performTransition(Transition.showMedia(media: user!.uploadedMedia, index: 0, sharing: false))
//    }

//    @IBAction func topBottomViewTapped(_ sender: UIButton) {
//        
//        userDidTapMoreInformation = true
//        view.endEditing(true)
//        let constant = bottomViewIsVisible ? 0 : -(profileImageView.frame.size.height+imagesCollectionView.frame.size.height+likeDislikeContainerView.frame.size.height)
//        bottomViewTopConstraint.constant = constant
//        UIView.animate(withDuration: 0.4, delay: 0.0, options: UIViewAnimationOptions(), animations: {
//            
//            self.view.layoutIfNeeded()
//        }) { (finished) in
//            
//            UIView.animate(withDuration: 0.4, delay: 0.0, options: UIViewAnimationOptions(), animations: {
//                
//                if self.bottomViewIsVisible {
//                    
//                    self.bottomViewButton.transform = CGAffineTransform.identity
//                } else {
//                    
//                    self.bottomViewButton.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
//                }
//            }, completion: { (finished) in
//                
//            })
//            self.bottomViewIsVisible = !self.bottomViewIsVisible
//        }
//    }
//
//    func showPassionList () {
//        userDidTapMoreInformation = true
//        view.endEditing(true)
//        let constant = bottomViewIsVisible ? 0 : -(profileImageView.frame.size.height+imagesCollectionView.frame.size.height+likeDislikeContainerView.frame.size.height)
//        bottomViewTopConstraint.constant = constant
//        UIView.animate(withDuration: 0.4, delay: 0.0, options: UIViewAnimationOptions(), animations: {
//            
//            self.view.layoutIfNeeded()
//        }) { (finished) in
//            
//            UIView.animate(withDuration: 0.4, delay: 0.0, options: UIViewAnimationOptions(), animations: {
//                
//                if self.bottomViewIsVisible {
//                    
//                    self.bottomViewButton.transform = CGAffineTransform.identity
//                } else {
//                    
//                    self.bottomViewButton.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
//                }
//            }, completion: { (finished) in
//                
//            })
//            self.bottomViewIsVisible = !self.bottomViewIsVisible
//        }
//    }



    
    // MARK: ImagePicker

//    func setImageAtIndex(_ image: UIImage, index: Int) {
//        
//        if index == 0 {
//            
//            profileImageView.image = image
//        } else if let cell = imagesCollectionView.cellForItem(at: IndexPath.init(row: 0, section: index)) as? ProfileImageCollectionViewCell {
//            
//            cell.imageView.image = image
//            cell.showDeleteButton(true)
//        }
//    }

//    // MARK: CarbonKit
//    func carbonTabSwipeNavigation(_ carbonTabSwipeNavigation: CarbonTabSwipeNavigation, viewControllerAt index: UInt) -> UIViewController {
//        
//        // return viewController at index
//        let tab = userTabs[Int(index)]
//        switch tab {
//        case .Moments:
//            let momentsViewController = MomentsViewController(momentsListType: .myMoments(userId: user!.objectId!))
//            momentsViewController.view.backgroundColor = UIColor.clear
//            momentsViewController.navigationCoordinator = navigationCoordinator
//            return momentsViewController
//        case .Map, .MyMap:
//            let tripsViewController = TripsViewController(user: user!)
//            return tripsViewController
//        case .Matches:
//            
//            if userMatchesViewController == nil {
//                userMatchesViewController = UserMatchesViewController(user: user!)
//                userMatchesViewController!.navigationCoordinator = navigationCoordinator
//            }
//            return userMatchesViewController!
//        default:
//            if User.userIsCurrentUser(user!) {
//                return SettingsViewController(user: user!)
//            } else {
//                return AboutViewController(user: user!)
//            }
//        }
//    }
