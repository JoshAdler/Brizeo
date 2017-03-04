//
//  MediaViewController.swift
//  Brizeo
//
//  Created by Arturo on 4/25/16.
//  Copyright © 2016 Kogi Mobile. All rights reserved.
//

import UIKit
import AlamofireImage
import MediaPlayer
import MobileCoreServices
import AVFoundation
import Branch
import SDWebImage
import MessageUI

class MediaViewController: UIViewController {
    
    // MARK: - Types
    
    struct StoryboardIds {
        static let mapSegueId = "showCoordinates"
    }
    
    // MARK: - Properties
    
    @IBOutlet fileprivate weak var bottomViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var collectionView: UICollectionView!
    @IBOutlet fileprivate weak var pageControl: UIPageControl!
    @IBOutlet fileprivate weak var locationButton: UIButton!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var shareButton: UIButton! {
        didSet {
            let tintImage = shareButton.image(for: .normal)!.withRenderingMode(.alwaysTemplate)
            shareButton.setImage(tintImage, for: .normal)
        }
    }
    
    fileprivate var willDisplayIndexPath: IndexPath?
    fileprivate var initialScrollDone = false
    
    var initialIndex = 0
    var isSharingEnabled = false
    var media: [FileObject]?
    var moment: Moment?
    
    //TODO: add sources of media to know whether we are using moments or not
    
    // MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shareButton.isHidden = !isSharingEnabled
        locationButton.isHidden = moment != nil && moment!.hasLocation
        descriptionTextView.isEditable = moment != nil && UserProvider.shared.currentUser!.objectId == moment!.ownerId
        
        if moment != nil {
            media = [FileObject(info: moment!.file)]
        }
        
        //TODO: ask Josh about: when is it possible to edit and when sharing?
        
        addDismissKeyboardGestureRecognizer()
        
        //TODO: place below in some place
        // track keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(didKeyboardWillShow(_:)), name: Foundation.Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didKeyboardWillHide(_:)), name: Foundation.Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        descriptionTextView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
        descriptionTextView.removeObserver(self, forKeyPath: "contentSize")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        view.layoutIfNeeded()
        
        pageControl.numberOfPages = media?.count ?? 0
        pageControl.isHidden = pageControl.numberOfPages < 2
        pageControl.currentPage = initialIndex
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !initialScrollDone {
            initialScrollDone = true
            
            collectionView.scrollToItem(at: IndexPath(row: initialIndex, section: 0), at: .centeredHorizontally, animated: false)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Observer methods
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        let textView = object as! UITextView
        var topCorrect = (textView.bounds.size.height - textView.contentSize.height * textView.zoomScale) / 2
        topCorrect = topCorrect < 0.0 ? 0.0 : topCorrect
        textView.contentInset.top = topCorrect
    }
    
    func didKeyboardWillShow(_ notification: Foundation.Notification){
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            bottomViewBottomConstraint.constant = keyboardSize.height - 50.0
            
            UIView.animate(withDuration: 0.5, animations: { 
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func didKeyboardWillHide(_ notification: Foundation.Notification){
        bottomViewBottomConstraint.constant = 0
        
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        })
    }

    // MARK: - Private methods
    
    fileprivate func playVideo(_ url: URL!) {
        guard let moviePlayer = MPMoviePlayerViewController(contentURL: url) else {
            print("Error. Can't initialize movie player")
            return
        }
        
        moviePlayer.view.frame = self.view.bounds
        present(moviePlayer, animated: true, completion: nil)
    }
    
    // MARK: - Segue methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardIds.mapSegueId {
            guard let destinationController = segue.destination as? MomentLocationViewController else {
                return
            }
            
            destinationController.coordinates = LocationManager.shared.currentLocationCoordinates?.coordinate
            destinationController.text = "Some text"
        }
    }
    
    // MARK: - Actions
    
    @IBAction func onLocationButtonClicked(sender: UIButton) {
        performSegue(withIdentifier: StoryboardIds.mapSegueId, sender: self)
    }
    
    @IBAction func onBackButtonClicked(_ sender: UIButton) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    //TODO: place corrent moment url
    @IBAction func onSharingButtonClicked(_ sender: UIButton) {
        BranchProvider.generateInviteURL(forMomentId: moment!.objectId, imageURL: nil) { (url) in
            if let url = url {
                if MFMessageComposeViewController.canSendText() {
                    let messageComposeVC = MFMessageComposeViewController()
                    messageComposeVC.body = url
                    messageComposeVC.delegate = self
                    messageComposeVC.messageComposeDelegate = self
                    messageComposeVC.recipients = nil
                    self.present(messageComposeVC, animated: true, completion: nil)
                }
            }
        }
    }
}

// MARK: - UICollectionViewDataSource
extension MediaViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return media?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MatchProfilePictureCollectionViewCell.identifier, for: indexPath) as! MatchProfilePictureCollectionViewCell
        
        let item = media![indexPath.row]
        
        switch item.type {
        case .video:
            cell.isPlayIconHidden = false
            cell.imageView.sd_setImage(with: URL(string: item.thumbFile!.url!))
            break
        case .image:
            cell.isPlayIconHidden = true
            cell.imageView.sd_setImage(with: URL(string: item.imageFile!.url!))
            break
        }

        // TODO: ask Josh what kind of resources can be used to a moment - image or video also?
        // TODO: ask Josh about what text should be placed on the media? Only if moment?
        descriptionTextView.text = moment != nil ? moment?.capture : nil
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension MediaViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        willDisplayIndexPath = indexPath
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if let willDisplayIndexPath = willDisplayIndexPath , willDisplayIndexPath != indexPath {
            pageControl.currentPage = willDisplayIndexPath.row
        }
        willDisplayIndexPath = nil
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = media![indexPath.row]
        
        switch item.type {
        case .video:
            if let urlStr = item.videoFile?.url, let url = URL(string: urlStr) {
                playVideo(url)
            }
            break
        default:
            break
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MediaViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
}

    // MARK: - MFMessageComposeViewControllerDelegate
    extension MediaViewController: MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate {
        
        func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            controller.dismiss(animated: true, completion: nil)
        }
}



