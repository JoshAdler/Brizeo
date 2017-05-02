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
import GBHFacebookImagePicker
import InstagramImagePicker

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
    @IBOutlet fileprivate weak var arrowUpButton: UIButton!
    
    weak var delegate: ProfileViewControllerDelegate?
    var index: Int = 0
    var user: User!
    var indexOfMediaToChange = -1
    var uploadUserHelpView: FirstEntranceUserView?
    var updateFileType: UpdateFileType = .main
    var isSelected = false
    
    var bottomSpaceHeight: CGFloat {
        return bottomView.frame.height
    }
    
    // MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        user = UserProvider.shared.currentUser!
        
        if user.hasProfileImage {
            profileImageView.sd_setImage(with: user.profileUrl)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Helper.mainTabBarController()?.tabBar.isHidden = true
    }
    
    // MARK: - Actions
    
    @IBAction func onBottomButtonClicked(_ sender: UIButton) {
        delegate?.shouldShowDetails()
    }
    
    @IBAction func onPhotoButtonClicked(_ sender: UIButton) {
        updateFileType = .main
        indexOfMediaToChange = 0 // profile media
        showNewMediaAlert(with: .photo)
    }
    
    @IBAction func onVideoButtonClicked(_ sender: UIButton) {
        updateFileType = .main
        indexOfMediaToChange = 0 // profile media
        showNewMediaAlert(with: .video)
    }
    
    @IBAction func onProfilePhotoClicked(_ sender: UIButton) {
        let mediaController: MediaViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.mediaController)!
        mediaController.initialIndex = 0
        mediaController.media = user.allMedia
        
        navigationController?.pushViewController(mediaController, animated: true)
    }
    
    // MARK: - Public methods
    
    func hideHelpView(isHidden: Bool) {
        if uploadUserHelpView == nil {
            uploadUserHelpView = FirstEntranceUserView.loadFromNib()
            uploadUserHelpView?.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
            uploadUserHelpView?.isHidden = true
            uploadUserHelpView?.delegate = self
            
            // count distances
            let globalPoint = arrowUpButton.superview!.convert(arrowUpButton.frame.origin, to: AppDelegate.shared().window)
            uploadUserHelpView!.bottomDistance = UIScreen.main.bounds.height - globalPoint.y - arrowUpButton.frame.height + 5.0 /* difference in sizes between icon image and real button */
            
            AppDelegate.shared().window?.addSubview(uploadUserHelpView!)
        }
        
        uploadUserHelpView?.isHidden = isHidden
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
        
        // action for image from library
        let libraryImageMedia = UIAlertAction(title: LocalizableString.PhotoLibrary.localizedString, style: UIAlertActionStyle.default, handler: {
            (alert: UIAlertAction!) -> Void in
            imagePicker.sourceType = .photoLibrary
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.modalPresentationStyle = .popover
            
            self.present(imagePicker, animated: true, completion: nil)
        })
        
        // action for video from library
        let libraryVideoMedia = UIAlertAction(title: LocalizableString.VideoLibrary.localizedString, style: UIAlertActionStyle.default, handler: {
            (alert: UIAlertAction!) -> Void in
            imagePicker.videoQuality = Configurations.Quality.videoQuality
            imagePicker.videoMaximumDuration = 14
            imagePicker.sourceType = .photoLibrary
            imagePicker.mediaTypes = [kUTTypeMovie as String]
            imagePicker.allowsEditing = true
            imagePicker.modalPresentationStyle = .popover
            
            self.present(imagePicker, animated: true, completion: nil)
        })
        
        // action for media from camera
        let cameraPhotoMedia = UIAlertAction(title: LocalizableString.TakeAPhoto.localizedString, style: UIAlertActionStyle.default, handler: {
            (alert: UIAlertAction!) -> Void in
            imagePicker.sourceType = .camera
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.showsCameraControls = true
            imagePicker.cameraCaptureMode = .photo
            imagePicker.modalPresentationStyle = .popover
            
            self.present(imagePicker, animated: true, completion: nil)
        })
        
        let cameraVideoMedia = UIAlertAction(title: LocalizableString.TakeAVideo.localizedString, style: UIAlertActionStyle.default, handler: {
            (alert: UIAlertAction!) -> Void in
            imagePicker.allowsEditing = true
            imagePicker.videoMaximumDuration = 14
            imagePicker.sourceType = .camera
            imagePicker.mediaTypes = [kUTTypeMovie as String]
            imagePicker.cameraCaptureMode = .video
            imagePicker.videoQuality = Configurations.Quality.videoQuality
            imagePicker.showsCameraControls = true
            imagePicker.modalPresentationStyle = .popover
            
            self.present(imagePicker, animated: true, completion: nil)
        })
        
        // action for media from camera
        let deleteMedia = UIAlertAction(title: LocalizableString.Delete.localizedString, style: UIAlertActionStyle.default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            guard self.indexOfMediaToChange >= 0 && self.indexOfMediaToChange < self.user.uploadFiles.count else {
                assertionFailure("Bad index for deleting a media")
                return
            }
            
            let oldUrl = self.user.uploadFiles[self.indexOfMediaToChange].mainUrl
            self.uploadFile(file: nil, self.updateFileType, oldUrl)
        })
        
        // action for facebook source
        let facebookAction = UIAlertAction(title: LocalizableString.TakeAPhotoFromFacebook.localizedString, style: UIAlertActionStyle.default, handler: {
            (alert: UIAlertAction!) -> Void in
            let picker = GBHFacebookImagePicker()
            picker.presentFacebookAlbumImagePicker(from: self, delegate: self)
        })
        
        // action for instagram source
        let instagramAction = UIAlertAction(title: LocalizableString.TakeAPhotoFromInstagram.localizedString, style: UIAlertActionStyle.default, handler: {
            (alert: UIAlertAction!) -> Void in
            guard let imagePicker = OLInstagramImagePickerController(clientId: Configurations.Instagram.clientId, secret: Configurations.Instagram.clientSecret, redirectURI: Configurations.Instagram.redirectURL) else {
                print("Can't create instagram controller")
                return
            }
            
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
        })
        
        let cancelAction = UIAlertAction(title: LocalizableString.Cancel.localizedString, style: UIAlertActionStyle.cancel, handler: nil)
        
        var alertTitle: String?
        
        switch source {
        case .photo:
            alertTitle = LocalizableString.newMomentImageSource.localizedString
            break
        case .video:
            alertTitle = LocalizableString.newMomentVideoSource.localizedString
            break
        case .photoVideo:
            alertTitle = LocalizableString.newMomentImageVideoSource.localizedString
            break
        case .photoVideoDelete:
            alertTitle = LocalizableString.newMomentImageVideoSource.localizedString
        }
        
        let alertView = UIAlertController(title: nil, message: alertTitle, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        switch source {
        case .photo:
            
            alertView.addAction(libraryImageMedia)
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) == true {
                alertView.addAction(cameraPhotoMedia)
            }
            
            alertView.addAction(facebookAction)
            alertView.addAction(instagramAction)
            
            break
        case.video:
            
            alertView.addAction(libraryVideoMedia)
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) == true {
                alertView.addAction(cameraVideoMedia)
            }
            
            break
        case .photoVideo, .photoVideoDelete:
            
            alertView.addAction(libraryImageMedia)
            alertView.addAction(libraryVideoMedia)
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) == true {
                alertView.addAction(cameraPhotoMedia)
                alertView.addAction(cameraVideoMedia)
            }
            
            alertView.addAction(facebookAction)
            alertView.addAction(instagramAction)
            
            if source == .photoVideoDelete {
                alertView.addAction(deleteMedia)
            }
        
            break
        }
        
        alertView.addAction(cancelAction)
        present(alertView, animated: true, completion: nil)
    }
    
    fileprivate func uploadFile(file: FileObject?, _ withType: UpdateFileType, _ url: String?) {
        
        showBlackLoader()
        
        UserProvider.updateUserFile(file: file, type: withType, oldURL: url) { [weak self] (result) in
            if let welf = self {
                
                welf.hideLoader()
                
                switch(result) {
                case .success(let user):
                    welf.user = user
                    
                    // update uploaded images
                    welf.imagesCollectionView.reloadData()
                    
                    // update user profile image
                    if welf.user.hasProfileImage {
                        welf.profileImageView.sd_setImage(with: welf.user.profileUrl)
                    }
                    
                    break
                case .failure(let error):
                    welf.presentErrorAlert(message: error.localizedDescription) {
                        welf.uploadFile(file: file, withType, url)
                    }
                    break
                default:
                    break
                }
            }
        }
    }
    
    fileprivate func presentErrorAlert(message: String?, againHandler: @escaping (Void) -> Void) {
        let alert = UIAlertController(title: LocalizableString.Error.localizedString, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: LocalizableString.TryAgain.localizedString, style: .default, handler: { (action) in
            againHandler()
        }))
        
        alert.addAction(UIAlertAction(title: LocalizableString.Dismiss.localizedString, style: .cancel, handler: { (action) in
            self.tabBarController?.selectedIndex = 2 /* go to moments */
        }))
        
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - UICollectionViewDataSource
extension ProfileViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Configurations.General.photosCountToLoadAtStart
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StoryboardIds.imageCell, for: indexPath) as! ProfileImageCollectionViewCell
        
        cell.delegate = self
        cell.imageView.image = #imageLiteral(resourceName: "ic_add_photo_plus")
        cell.isDeleteButtonHidden = true
        
        if indexPath.row < user.uploadFiles.count {
            if let imageURL = user.uploadFiles[indexPath.row].imageUrl {
                cell.imageView.sd_setImage(with: imageURL)
                cell.isDeleteButtonHidden = false
            } else {
                cell.imageView.image = nil
            }
        } else {
            cell.imageView.image = #imageLiteral(resourceName: "ic_add_photo_plus")
        }
    
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension ProfileViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row < user.uploadFiles.count { // show media
            let mediaController: MediaViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.mediaController)!
            mediaController.initialIndex = indexPath.row + 1
            mediaController.media = user.allMedia
            
            navigationController?.pushViewController(mediaController, animated: true)
        } else { // plus button
            indexOfMediaToChange = -1
            updateFileType = .other
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

        picker.dismiss(animated: true, completion: nil)
        
        // create file
        var file: FileObject? = nil
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let fixedImage = pickedImage.fixedOrientation()
            let compressedImage = Helper.compress(image: fixedImage)
            let fileInfo = FileObjectInfo(image: compressedImage)
            
            file = FileObject(info: fileInfo)
        }
        
        if let videoURL = info[UIImagePickerControllerMediaURL] as? URL {
            let thumbnailImage = Helper.generateThumbnail(from: videoURL)!
            let compresedImage = Helper.compress(image: thumbnailImage)
            let thumbnailFileInfo = FileObjectInfo(image: compresedImage)
            let fileInfo = FileObjectInfo(url: videoURL)
            
            file = FileObject(thumbnailImage: thumbnailFileInfo, videoInfo: fileInfo)
        }
        
        // get old url/new file
        var oldUrl: String? = nil
        if indexOfMediaToChange != -1 {
            if indexOfMediaToChange < user.uploadFiles.count {
                oldUrl = user.uploadFiles[self.indexOfMediaToChange].mainUrl
            }
        }
        
        uploadFile(file: file, updateFileType, oldUrl)
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
        
        updateFileType = .other
        indexOfMediaToChange = indexPath.row
        showNewMediaAlert(with: .photoVideoDelete)
    }
}

// MARK: - FirstEntranceUserViewDelegate
extension ProfileViewController: FirstEntranceUserViewDelegate {
    
    func userView(view: FirstEntranceUserView, didClickedOnArrowUp button: UIButton) {
        view.isHidden = true
        onBottomButtonClicked(arrowUpButton)
    }
}

// MARK: - GBHFacebookImagePickerDelegate
extension ProfileViewController: GBHFacebookImagePickerDelegate {
    
    func facebookImagePicker(imagePicker: UIViewController, imageModel: GBHFacebookImage) {
        
        DispatchQueue.main.async {
            
            if let pickedImage = imageModel.image {
                
                let compressedImage = Helper.compress(image: pickedImage)
                
                // create file
                let file: FileObject = FileObject(info: FileObjectInfo(image: compressedImage))
                
                // get old url/new file
                var oldUrl: String? = nil
                if self.indexOfMediaToChange != -1 {
                    if self.indexOfMediaToChange < self.user.uploadFiles.count {
                        oldUrl = self.user.uploadFiles[self.indexOfMediaToChange].mainUrl
                    }
                }
                
                self.uploadFile(file: file, self.updateFileType, oldUrl)
            }
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
extension ProfileViewController: OLInstagramImagePickerControllerDelegate {
    
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
        
        showBlackLoader()
        
        // load image
        SDWebImageManager.shared().downloadImage(with: instagramImage.fullURL, options: SDWebImageOptions.highPriority, progress: { (currentBytes, totalBytes) in
        }) { (image, error, cacheType, finished, url) in
            DispatchQueue.main.async {
                self.hideLoader()
                
                if image != nil {
                    
                    let compressedImage = Helper.compress(image: image!)
                    
                    // create file
                    let file: FileObject = FileObject(info: FileObjectInfo(image: compressedImage))
                    
                    // get old url/new file
                    var oldUrl: String? = nil
                    if self.indexOfMediaToChange != -1 {
                        if self.indexOfMediaToChange < self.user.uploadFiles.count {
                            oldUrl = self.user.uploadFiles[self.indexOfMediaToChange].mainUrl
                        }
                    }
                    
                    self.uploadFile(file: file, self.updateFileType, oldUrl)
                }
            }
        }
    }
    
    func instagramImagePicker(_ imagePicker: OLInstagramImagePickerController!, shouldSelect image: OLInstagramImage!) -> Bool {
        return (imagePicker.selected.count < 1)
    }
}
