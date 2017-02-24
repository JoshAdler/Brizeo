////
////  MatchStartChatViewController.swift
////  Brizeo
////
////  Created by Arturo on 4/25/16.
////  Copyright © 2016 Kogi Mobile. All rights reserved.
////
//
//import UIKit
//import AlamofireImage
//import LayerKit
//import Crashlytics
//
//class MatchStartChatViewController: UIViewController, Transitionable {
//
//    @IBOutlet fileprivate weak var titleLabel: UILabel!
//    @IBOutlet fileprivate weak var subTitleLabel: UILabel!
//    @IBOutlet fileprivate weak var matchImageView: UIImageView!
//    @IBOutlet fileprivate weak var startChattingButton: UIButton!
//    @IBOutlet fileprivate weak var returnToSearchButton: UIButton!
//    fileprivate var user : User
//    weak var delegate: UserMatchesActionDelegate?
//    weak var navigationCoordinator: CoordinatorType?
//    fileprivate var conversation : LYRConversation?
//    

//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Do any additional setup after loading the view.
//        setupUI()
//        createConversation()
//    }
//    
//    // MARK: SetupUI
//    func setupUI() {
//        
//        titleLabel.text = LocalizableString.ItsAMatch.localizedString
//        subTitleLabel.text = LocalizableString.LetTheJourneyBegin.localizedString
//        startChattingButton.setTitle(LocalizableString.StartChatting.localizedString, for: UIControlState())
//        returnToSearchButton.setTitle(LocalizableString.ReturnToSearch.localizedString, for: UIControlState())
//        if let url = user.profileImageUrl {
//            matchImageView.af_setImage(withURL: url)
//        }
//    }
//    
//    func createConversation() {
//        
//        conversation = LayerManager.conversationBetweenUser(User.current()!.objectId!, andUserId: user.objectId!, message: LocalizableString.ItsAMatch.localizedString)
//        PushNotificationManager.sharedInstance().sendPush(user, text: LocalizableString.YouveMatchedWith.localizedStringWithArguments([User.current()!.displayName]))
//    }
//    
//    // MARK: Actions
//    
//    @IBAction func startChattingButtonTapped(_ sender: UIButton) {
//        
//        if let conversation = conversation {
//            
//            dismissModalView(true, completion: {
//                self.navigationCoordinator?.performTransition(Transition.chatView(conversation: conversation))
//                self.delegate?.userDidLikeDislikeUser(self, loadNext: false)
//            })
//        }
//    }
//    
//    @IBAction func returnToSearchButtonTapped(_ sender: UIButton) {
//        
//        dismissModalView(true, completion: nil)
//        delegate?.userDidLikeDislikeUser(self, loadNext: true)
//    }
//    
//    // MARK: PresentViewController
//    func presentModalViewOverViewController(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
//        
//        var frame = viewController.view.bounds
//        frame.origin.y = frame.size.height
//        view.frame = frame
//        viewController.view.addSubview(view)
//        viewController.addChildViewController(self)
//        didMove(toParentViewController: viewController)
//        UIView.animate(withDuration: animated ? 0.2 : 0.0, delay: 0.0, options: UIViewAnimationOptions(), animations: {
//            
//            var frame = self.view.frame
//            frame.origin.y = 0
//            self.view.frame = frame
//            
//            }) { (finished) in
//                
//            completion?()
//        }
//    }
//    
//    func dismissModalView(_ animated: Bool, completion: (() -> Void)?) {
//        
//        UIView.animate(withDuration: animated ? 0.2 : 0.0, delay: 0.0, options: UIViewAnimationOptions(), animations: {
//            
//            var frame = self.view.frame
//            frame.origin.y = frame.size.height
//            self.view.frame = frame
//            
//        }) { (finished) in
//            completion?()
//            self.willMove(toParentViewController: nil)
//            self.view.removeFromSuperview()
//            self.removeFromParentViewController()
//        }
//    }
//}
