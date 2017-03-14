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
        
        // action for media from library
        let libraryMedia = UIAlertAction(title: LocalizableString.Library.localizedString, style: UIAlertActionStyle.default, handler: {
            (alert: UIAlertAction!) -> Void in
            imagePicker.allowsEditing = true
            imagePicker.videoQuality = UIImagePickerControllerQualityType.typeHigh
            imagePicker.videoMaximumDuration = 14
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
            
            guard self.indexOfMediaToChange >= 0 && self.indexOfMediaToChange < (self.user.uploadFiles?.count ?? 0) else {
                assertionFailure("Bad index for deleting a media")
                return
            }
            
            let oldUrl = self.user.uploadFiles?[self.indexOfMediaToChange].mainUrl
            self.uploadFile(file: nil, self.updateFileType, oldUrl)
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
    
    fileprivate func uploadFile(file: FileObject?, _ withType: UpdateFileType, _ url: String?) {
        
        showBlackLoader()
        
        UserProvider.updateUserFile(file: file, type: withType, oldURL: url) { [weak self] (result) in
            if let welf = self {
                
                welf.hideLoader()
                
                switch(result) {
                case .success(_):
                    print("wow")
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

        //TODO: check whether it can be video here.
        if indexPath.row < (user.uploadFiles?.count ?? 0) {
            if let imageURL = user.uploadFiles?[indexPath.row].imageFile?.url {
                cell.imageView.sd_setImage(with: URL(string: imageURL))
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
    //TODO: check whether it is clicking okay with many uploaded files/idnexes/crashes
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row < (user.uploadFiles?.count ?? 0) { // show media
            let mediaController: MediaViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.mediaController)!
            mediaController.initialIndex = indexPath.row + 1
            mediaController.media = user.allMedia
            
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

        picker.dismiss(animated: true, completion: nil)
        
        // create file
        var file: FileObject? = nil
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let fileInfo = FileObjectInfo(image: pickedImage)
            file = FileObject(info: fileInfo)
        }
        
        if let videoURL = info[UIImagePickerControllerMediaURL] as? URL {
            let thumbnailFileInfo = FileObjectInfo(image: Helper.generateThumbnail(from: videoURL)!)
            let fileInfo = FileObjectInfo(url: videoURL)
            file = FileObject(thumbnailImage: thumbnailFileInfo, videoInfo: fileInfo)
        }
        
        // get old url/new file
        var oldUrl: String? = nil
        if indexOfMediaToChange != -1 {
            if indexOfMediaToChange < (user.uploadFiles?.count ?? 0) {
                oldUrl = user.uploadFiles?[indexOfMediaToChange].mainUrl
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

