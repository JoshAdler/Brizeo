//
//  MatchNotificationViewController.swift
//  Brizeo
//
//  Created by Monkey on 9/15/16.
//  Copyright © 2016 Kogi Mobile. All rights reserved.
//

import UIKit
import CarbonKit

class MatchNotificationViewController: UIViewController, Transitionable, RecipePickerViewControllerDelegate, CarbonTabSwipeNavigationDelegate, AboutViewControllerDelegate, UITabBarControllerDelegate{

    @IBOutlet weak var mainContainerView: UIView!
    @IBOutlet weak var bottomViewContainerView: UIView!
    @IBOutlet weak var bottomViewButton: UIButton!
    @IBOutlet weak var bottomViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonWidth: NSLayoutConstraint!
    
    
    fileprivate var profileViewController: ProfileViewController?
    fileprivate var recipePickerViewController: RecipePickerViewController?
    fileprivate var userDidTapMoreInformation = false
    fileprivate var bottomViewIsVisible = false
    //Variables
    var potentialMatches = [User]()
    fileprivate var currentUser: User
    fileprivate var user: User!
    fileprivate var userMatchesViewController : UserMatchesViewController?
    fileprivate var userDidTapMomments = false
    fileprivate var carbonTabSwipeNavigation: CarbonTabSwipeNavigation?
    fileprivate var isShowingMedia: Bool = false
    fileprivate var isEnd: Bool = false
    var navigationCoordinator: CoordinatorType?
    
    fileprivate var userTabs: [LocalizableString] {
        
        guard let user = user else {
            return []
        }
        
        if User.userIsCurrentUser(user) {
            return [.About, .Matches, .MyMap]
        } else {
            return [.About, .Moments, .Map]
        }
    }
    
    init() {
        
        currentUser = User.current()!
        super.init(nibName: String(describing: MatchNotificationViewController()), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.delegate = self
        
        let frame = UIScreen.main.bounds
        let titleImgView = UIImageView(frame: CGRect(x: frame.size.width / 2.0 - 60, y: 10, width: 120, height: 25))
        titleImgView.image = UIImage(named: "Brizeo")
        titleImgView.contentMode = .scaleAspectFit
        titleImgView.tag = 1000
        titleImgView.backgroundColor = UIColor.white
        let navVC = self.navigationController
        navVC!.navigationBar.addSubview(titleImgView)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(rightNavigationButtonClicked))
        navigationItem.rightBarButtonItem = UIBarButtonItem()
        // Do any additional setup after loading the view.
        loadProfile()
        
        NotificationCenter.default.addObserver(self, selector: #selector(startChatting), name: NSNotification.Name(rawValue: LocalizableString.ItsAMatch.localizedString), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: LocalizableString.ItsAMatch.localizedString), object: nil)
    }
    
    override func rightNavigationButtonClicked() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
         (self.navigationCoordinator?.baseController as! UINavigationController).popViewController(animated: false)
        
        super.viewWillAppear(animated)
        if isEnd {
            self.showAlert(LocalizableString.Brizeo.localizedString, message: LocalizableString.NotFoundNotification.localizedString, dismissTitle: LocalizableString.Done.localizedString, completion: {
                self.navigationController?.dismiss(animated: true, completion: nil)
            })
        }
        userMatchesViewController?.viewWillAppear(animated)
    }
    
    // MARK: SetupUI
    func setUpUI() {
        
        var items = [String]()
        for tab in userTabs {
            items.append(tab.localizedString.uppercased())
        }
        let color = UIColor(colorLiteralRed: 0.0/255.0, green: 104/255.0, blue: 217/255.0, alpha: 1.0)
        let width = UIScreen.main.bounds.width
        carbonTabSwipeNavigation = CarbonTabSwipeNavigation(items: items, delegate: self)
        carbonTabSwipeNavigation!.insert(intoRootViewController: self, andTargetView: bottomViewContainerView)
        carbonTabSwipeNavigation!.view.backgroundColor = UIColor.clear
        carbonTabSwipeNavigation!.setIndicatorHeight(4.0)
        carbonTabSwipeNavigation?.setIndicatorColor(color)
        carbonTabSwipeNavigation!.setTabExtraWidth(10)
        for i in 0 ... items.count - 1 {
            carbonTabSwipeNavigation?.carbonSegmentedControl?.setWidth(width / CGFloat(items.count), forSegmentAt: i)
        }
        carbonTabSwipeNavigation!.setNormalColor(UIColor.black, font: UIFont(name: "HelveticaNeue-Light", size: 17.0)!)
        carbonTabSwipeNavigation!.setSelectedColor(UIColor.color(11.0, green: 106.0, blue: 216.0), font: UIFont(name: "HelveticaNeue-Light", size: 17.0)!)
        carbonTabSwipeNavigation!.toolbar.barTintColor = UIColor.white
        
    }
    
    func loadProfile() {
        
        self.user = potentialMatches.first
        self.resetBottomView()
        self.setUpUI()
        animateTransition(true, animated: true, completion: nil)
        recipePickerViewController = RecipePickerViewController()
        recipePickerViewController!.isNotification = true
        var potentialUser = [DisplayItem]()
        for match in potentialMatches {
            potentialUser.append(DisplayItem(user: match, showingDetail: false))
            print(match)
        }
        recipePickerViewController?.users = potentialUser
        recipePickerViewController?.delegate = self
        loadSearchMatchView()
    }
    
    func removeProfileView() {
        
        recipePickerViewController?.willMove(toParentViewController: nil)
        recipePickerViewController?.view.removeFromSuperview()
        recipePickerViewController?.removeFromParentViewController()
    }
    
    func loadProfileView() {
        
        guard let recipePickerViewController = recipePickerViewController else {
            return
        }
        
        mainContainerView.addSubview(recipePickerViewController.view)
        recipePickerViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        mainContainerView.addConstraint(NSLayoutConstraint(item: recipePickerViewController.view, attribute: .top, relatedBy: .equal, toItem: mainContainerView, attribute: .top, multiplier: 1.0, constant: 0.0))
        mainContainerView.addConstraint(NSLayoutConstraint(item: recipePickerViewController.view, attribute: .bottom, relatedBy: .equal, toItem: mainContainerView, attribute: .bottom, multiplier: 1.0, constant: 0.0))
        mainContainerView.addConstraint(NSLayoutConstraint(item: recipePickerViewController.view, attribute: .leading, relatedBy: .equal, toItem: mainContainerView, attribute: .leading, multiplier: 1.0, constant: 0.0))
        mainContainerView.addConstraint(NSLayoutConstraint(item: recipePickerViewController.view, attribute: .trailing, relatedBy: .equal, toItem: mainContainerView, attribute: .trailing, multiplier: 1.0, constant: 0.0))
        
        addChildViewController(recipePickerViewController)
        recipePickerViewController.didMove(toParentViewController: self)
    }
    
    func loadSearchMatchView() {
        
        guard let recipePickerViewController = recipePickerViewController else {
            return
        }
        
        mainContainerView.addSubview(recipePickerViewController.view)
        recipePickerViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        mainContainerView.addConstraint(NSLayoutConstraint(item: recipePickerViewController.view, attribute: .top, relatedBy: .equal, toItem: mainContainerView, attribute: .top, multiplier: 1.0, constant: 0.0))
        mainContainerView.addConstraint(NSLayoutConstraint(item: recipePickerViewController.view, attribute: .bottom, relatedBy: .equal, toItem: mainContainerView, attribute: .bottom, multiplier: 1.0, constant: 0.0))
        mainContainerView.addConstraint(NSLayoutConstraint(item: recipePickerViewController.view, attribute: .leading, relatedBy: .equal, toItem: mainContainerView, attribute: .leading, multiplier: 1.0, constant: 0.0))
        mainContainerView.addConstraint(NSLayoutConstraint(item: recipePickerViewController.view, attribute: .trailing, relatedBy: .equal, toItem: mainContainerView, attribute: .trailing, multiplier: 1.0, constant: 0.0))
        
        addChildViewController(recipePickerViewController)
        recipePickerViewController.didMove(toParentViewController: self)
    }
    
    func startChatting(_ notification: Foundation.Notification) {
        let userInfo = (notification as NSNotification).userInfo
        let matchUser = userInfo!["matchedUser"]
        isShowingMedia = true
        navigationCoordinator?.performTransition(Transition.didFindMatch(user: matchUser as! User, userMatchesActionDelegate: nil))
    }
    
    func animateTransition(_ show: Bool, animated: Bool, completion: ((Bool) -> Void)?) {
        
        UIView.animate(withDuration: animated ? 0.2 : 0.0, animations: {
            
            self.mainContainerView.alpha = show ? 1.0 : 0.0
            if show {
                self.hideLoader()
            } else {
                self.showBlackLoader()
            }
            }, completion: completion)
    }
    
    // Mark: Helper
    func removeDuplicates(_ array: [DisplayItem]) -> [DisplayItem] {
        
        var encountered = Set<DisplayItem>()
        var result: [DisplayItem] = []
        for value in array {
            if encountered.contains(value) {
                // Do not add a duplicate element.
            }
            else {
                // Add value to the set.
                encountered.insert(value)
                // ... Append the value.
                result.append(value)
            }
        }
        return result
    }
    
    // MARK: ProfileViewControllerDelegate
    
    func showUploadedMedia(_ user: User) {
        isShowingMedia = true
        if user.uploadedMedia.count > 0 {
            let mediaViewController = MediaViewController(media: user.uploadedMedia, indexToStartOn: 0, sharing: false)
            self.navigationController!.present(mediaViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func topBottomViewTapped(_ sender: UIButton) {
        
        userDidTapMoreInformation = true
        view.endEditing(true)
        let constant = bottomViewIsVisible ? -0 : self.mainContainerView.frame.size.height - 60
        let constant1 = bottomViewIsVisible ? 60 : self.mainContainerView.frame.size.width
        bottomViewTopConstraint.constant = constant
        buttonWidth.constant = constant1
        UIView.animate(withDuration: 0.4, delay: 0.0, options: UIViewAnimationOptions(), animations: {
            
            self.view.layoutIfNeeded()
        }) { (finished) in
            
            UIView.animate(withDuration: 0.4, delay: 0.0, options: UIViewAnimationOptions(), animations: {
                
                if self.bottomViewIsVisible {
                    
                    self.bottomViewButton.transform = CGAffineTransform.identity
                } else {
                    
                    self.bottomViewButton.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
                }
                }, completion: { (finished) in
                    
            })
            self.bottomViewIsVisible = !self.bottomViewIsVisible
        }
    }
    
    func resetBottomView() {
        for view in bottomViewContainerView.subviews {
            view.removeFromSuperview()
        }
    }
    
    // MARK: RecipePickerViewControllerDelegate
    func nextUser(_ user: User) {
        self.user = user
        self.resetBottomView()
        setUpUI()
    }
    
    func userLike(_ user: User) {
        isEnd = true
    }
    
    func userDislike(_ user: User) {
        isEnd = true
    }
    
    //MARK: - AboutViewControllerDelegate
    func mutualFriendsCount(_ count: Int) {
        let count = String(format: "%d", count)
        self.recipePickerViewController!.setMutuarialFriendCount(count)
    }
    
    // MARK: CarbonKit
    func carbonTabSwipeNavigation(_ carbonTabSwipeNavigation: CarbonTabSwipeNavigation, viewControllerAt index: UInt) -> UIViewController {
        
        // return viewController at index
        let tab = userTabs[Int(index)]
        switch tab {
        case .Moments:
            let momentsViewController = MomentsViewController(momentsListType: .myMoments(userId: user!.objectId!))
            momentsViewController.view.backgroundColor = UIColor.clear
            return momentsViewController
        case .Map, .MyMap:
            let tripsViewController = TripsViewController(user: user!)
            return tripsViewController
        case .Matches:
            
            if userMatchesViewController == nil {
                userMatchesViewController = UserMatchesViewController(user: user!)
            }
            return userMatchesViewController!
        default:
            if User.userIsCurrentUser(user!) {
                return SettingsViewController(user: user!)
            } else {
                let aboutVC = AboutViewController(user: user!)
                aboutVC.delegate = self
                return aboutVC
            }
        }
    }
    
    func carbonTabSwipeNavigation(_ carbonTabSwipeNavigation: CarbonTabSwipeNavigation, didMoveAt index: UInt) {
        
        let tab = userTabs[Int(index)]
        userDidTapMomments = (tab == .Moments)
    }
}

