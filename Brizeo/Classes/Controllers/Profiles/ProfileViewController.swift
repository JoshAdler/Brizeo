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
            guard self.indexOfMediaToChange > 0 && self.indexOfMediaToChange < (self.user.uploadFiles?.count ?? 0) else {
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
        
//        if User.current()?.uploadImages?.count == 1 {
//            self.shouldGotoMomentView = true
//        }
//        
        
        picker.dismiss(animated: true, completion: nil)
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
        //      createNewMoment(with: pickedImage, videoURL: nil)
            return
        }
        
        if let videoURL = info[UIImagePickerControllerMediaURL] as? URL {
        //    createNewMoment(with: nil, videoURL: videoURL)
            return
        }
        
        
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

// MARK: - FirstEntranceUserViewDelegate
extension ProfileViewController: FirstEntranceUserViewDelegate {
    
    func userView(view: FirstEntranceUserView, didClickedOnArrowUp button: UIButton) {
        view.isHidden = true
        onBottomButtonClicked(arrowUpButton)
    }
}

