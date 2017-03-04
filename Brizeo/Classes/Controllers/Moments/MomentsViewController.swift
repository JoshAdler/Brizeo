//
//  MomentsViewController.swift
//  Brizeo
//
//  Created by Roman Bayik on 1/30/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import SVProgressHUD
import UIScrollView_InfiniteScroll
import Parse
import ChameleonFramework
import SDWebImage

let removedMomentNotification = "removedMomentNotification"

class MomentsViewController: UIViewController {

    // MARK: - Types
    
    struct Constants {
        static let backButtonColor = HexColor("1f4ba5")!
        static let cellHeightCoef: CGFloat = 564.0 / 750.0
//        static let cornerRadius: CGFloat = 3.0
//        static let borderWidth: CGFloat = 1.0
    }
    
    struct StoryboardIds {
        static let likesControllerId = "LikesViewController"
        static let otherProfileControllerId = "OtherProfileViewController"
        static let profileControllerId = "PersonalTabsViewController"
        static let mediaControllerId = "MediaViewController"
    }
    
    // MARK: - Properties

    @IBOutlet weak fileprivate var filterView: UIView!
    @IBOutlet weak fileprivate var tableViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak fileprivate var momentsTableView: UITableView!
    @IBOutlet weak fileprivate var addMomentButton: UIButton!
    @IBOutlet weak fileprivate var newestButton: UIButton!
    @IBOutlet weak fileprivate var popularButton: UIButton!
    @IBOutlet weak fileprivate var filterButton: DropMenuButton! {
        didSet {
            //TODO: check whether it is done, if yes - remove code below
//            filterButton.backgroundColor = .clear
//            filterButton.layer.cornerRadius = Constants.cornerRadius
//            filterButton.layer.borderWidth = Constants.borderWidth
//            filterButton.layer.borderColor = HexColor("dbdbdb")!.cgColor
        }
    }
    
    var listType: MomentsListType = .allMoments(userId: "0")
    var currentUser: User! = UserProvider.shared.currentUser!
    var shouldHideFilterView: Bool = false
    
    weak var parentDelegate: MomentsTabsViewControllerDelegate?
    
    fileprivate var paginator = PaginationHelper(pagesSize: 20)
    fileprivate var moments: [Moment]?
    fileprivate var sortedMoments: [Moment]?
    fileprivate var passions: [Passion]?
    fileprivate var selectedPassion: Passion?
    
    // MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        
        momentsTableView.addInfiniteScroll { [unowned self] (tableView) in
            self.paginator.increaseCurrentPage()
            self.loadMoments(with: false)
        }

        NotificationCenter.default.addObserver(self, selector: #selector(MomentsViewController.updateTableView), name: NSNotification.Name(rawValue: removedMomentNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MomentsViewController.updateTableView), name: NSNotification.Name(rawValue: LocalizableString.SomebodyLikeYourMoment.localizedString), object: nil)
        
        fetchPassions()
        initFilterButton()
        hideFilterViewIfNeeds()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let count = moments?.count ?? 0
        if count == 0 {
            momentsTableView.isHidden = true
            loadMoments(with: true)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        LocationManager.shared.checkAccessStatus()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Actions
    
    func onFilterButtonClicked(_ index: Int) {
        if index == 0 { // no filter
            
        } else {
            
        }
    }
    
    @IBAction func onCreateButtonClicked(_ sender: UIButton) {
        parentDelegate?.onCreateMoment()
    }
    
    @IBAction func onPopularButtonClicked(_ sender: UIButton) {
        enableRadioForButton(button: sender)
    }
    
    @IBAction func onNewestButtonClicked(_ sender: UIButton) {
        enableRadioForButton(button: sender)
    }
    
    // MARK: - Public methods
    
    func hideFilterViewIfNeeds() {
        if shouldHideFilterView {
            tableViewTopConstraint.constant = -filterView.frame.height
            filterView.isHidden = true
        }
    }
    
    func updateTableView() {
        resetMoments()
    }
    
    func gotoFirst() {
        momentsTableView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
    }
    
    func refreshTableView(_ sender: UIRefreshControl) {
        sender.endRefreshing()
        resetMoments()
    }
    // TODO: ask Josh about readStatus. what is this?
    
    // MARK: - Private methods
    
    fileprivate func showMomentUserProfile(_ moment: Moment) {
        if moment.ownerId == UserProvider.shared.currentUser!.objectId { // show my profile
            let profileController: PersonalTabsViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.profileControllerId)!
            Helper.initialNavigationController().pushViewController(profileController, animated: true)
        } else {
            let otherPersonProfileController: OtherProfileViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.otherProfileControllerId)!
            Helper.initialNavigationController().pushViewController(otherPersonProfileController, animated: true)
        }
        GoogleAnalyticsManager.userGoToProfileFromMoment.sendEvent()
    }
    
    
    fileprivate func likeMoment(_ moment: Moment) {
        showBlackLoader()
        
        MomentsProvider.likeMoment(moment) { (result) in
            self.hideLoader()
            
            switch result {
            case .success(_):
                GoogleAnalyticsManager.userHitLikeMoment.sendEvent()
                self.momentsTableView.reloadData()
            case .failure(let error):
                self.showAlert(LocalizableString.Error.localizedString, message: error, dismissTitle: LocalizableString.Ok.localizedString, completion: nil)
                break
            }
        }
    }
    
    fileprivate func unlikeMoment(_ moment: Moment) {
        showBlackLoader()
        
        MomentsProvider.unlikeMoment(moment) { (result) in
            self.hideLoader()
        
            switch result {
            case .success(_):
                self.momentsTableView.reloadData()
            case .failure(let error):
                self.showAlert(LocalizableString.Error.localizedString, message: error, dismissTitle: LocalizableString.Ok.localizedString, completion: nil)
                break
            }
        }
    }
    
    fileprivate func fetchPassions() {
        showBlackLoader()
        
        PassionsProvider.shared.retrieveAllPassions(true) { (result) in
            DispatchQueue.main.async {
                self.hideLoader()
                
                switch result {
                case .success(let passions):
                    self.passions = passions
                    self.initFilterButton()
                case .failure(let error):
                    self.showAlert(LocalizableString.Error.localizedString, message: error, dismissTitle: LocalizableString.Dismiss.localizedString, completion: nil)
                }
            }
        }
    }
    //TODO: retry buttons for error alerts
    fileprivate func initFilterButton() {
        guard passions != nil else {
            return
        }
        
        selectedPassion = passions!.filter({ $0.displayName == "Travel" }).first ?? passions!.first!
        
        // set default value
        filterButton.setTitle(selectedPassion!.displayName, for: .normal)
        filterButton.isEnabled = true
        
        var handlers = [() -> Void]()
        
        for i in 0 ..< passions!.count {
            handlers.append({ [weak self] () -> (Void) in
                self?.onFilterButtonClicked(i)
            })
        }
        
        let passionStrings = passions!.map({ $0.displayName })
        filterButton.initMenu(passionStrings, actions: handlers)
    }
    
    fileprivate func enableRadioForButton(button: UIButton) {
        newestButton.isSelected = button == newestButton
        popularButton.isSelected = button == popularButton
    }
    
    fileprivate func setupTableView() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(MomentsViewController.refreshTableView), for: .valueChanged)
        
        momentsTableView.rowHeight = UITableViewAutomaticDimension
        momentsTableView.estimatedRowHeight = 400
        momentsTableView.tableFooterView = UIView()
        momentsTableView.addSubview(refreshControl)
    }
    
    fileprivate func resetMoments() {
        paginator.resetPages()
        loadMoments(with: true)
    }
    
    fileprivate func loadMoments(with centerLoading: Bool) {
        if centerLoading {
            SVProgressHUD.show()
        }
        
//        MomentsProvider.getMomentsList(listType, sort: isNew, paginator: paginator) { [unowned self] (result) in
//            
//            switch result {
//            case .success(let moments):
//                SVProgressHUD.dismiss()
//                
//                if self.moments == nil {
//                    self.moments = [Moment]()
//                }
//                
//                // prefetch moments
//                var urls = [URL]()
//                for moment in moments {
//                    if moment.imageUrl != nil {
//                        urls.append(moment.imageUrl!)
//                    }
//                }
//                SDWebImagePrefetcher.shared().prefetchURLs(urls)
//                
//                self.paginator.addNewElements(&self.moments!, newElements: moments)
//                self.momentsTableView.reloadData()
//                break
//            case .failure(let error):
//                SVProgressHUD.showError(withStatus: error)
//                break
//            }
//            
//            self.momentsTableView.isHidden = false
//            self.momentsTableView.finishInfiniteScroll()
//        }
    }
}

//MARK: - UITableViewDataSource
extension MomentsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return moments?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let moment = moments![indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: MomentTableViewCell.identifier) as! MomentTableViewCell
        
        cell.delegate = self
        //cell.ownerNameLabel.text = moment.user.displayName
        cell.momentDescriptionLabel.text = moment.capture
        cell.numberOfLikesButton.setTitle("\(moment.likesCount)", for: .normal)
        cell.likeButton.isHidden = moment.ownerId == currentUser.objectId
        cell.setButtonHighligted(isHighligted: moment.isLikedByCurrentUser)
        
        cell.momentImageView.sd_setImage(with: moment.imageUrl)
//        cell.ownerLogoButton.sd_setImage(with: moment.user.profileUrl, for: .normal)
        
        cell.actionButton.isEnabled = true
        if moment.ownerId != currentUser.objectId/* && moment.user.isSuperUser*/ {
            cell.actionButton.isEnabled = false
        }
        
        cell.notificationView.isHidden = true
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension MomentsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.cellHeightCoef * tableView.frame.width
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 320.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let moment = moments?[indexPath.row] else {
            print("Click on nothing. Can't be called")
            return
        }
        
        let mediaController: MediaViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.mediaControllerId)!
        mediaController.isSharingEnabled = true
        mediaController.moment = moment
        
        Helper.initialNavigationController().pushViewController(mediaController, animated: true)
    }
}

//MARK: - MomentCellDelegate Methods
extension MomentsViewController: MomentTableViewCellDelegate {
    
    func momentCellDidSelectLike(_ cell: MomentTableViewCell) {
        guard let indexPath = momentsTableView.indexPath(for: cell) else {
            print("No index path for cell")
            return
        }
        
        guard let moment = moments?[indexPath.row] else {
            print("No moment for this index path")
            return
        }
        
        if moment.isLikedByCurrentUser {
            unlikeMoment(moment)
        } else {
            likeMoment(moment)
        }
    }

    func momentCellDidSelectMomentLikes(_ cell: MomentTableViewCell) {
        guard let indexPath = momentsTableView.indexPath(for: cell) else {
            print("No index path for cell")
            return
        }
        
        guard let moment = moments?[indexPath.row] else {
            print("No moment for this index path")
            return
        }
        //TODO: ask Josh about read status of moments and perhaps others?
        //checkReadStatus(moment)
        
        let likersController: LikesViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.likesControllerId)!
        likersController.moment = moment
        
        Helper.initialNavigationController().pushViewController(likersController, animated: true)
    }
    
    func momentCellDidSelectOwnerProfile(_ cell: MomentTableViewCell) {
        guard let indexPath = momentsTableView.indexPath(for: cell) else {
            print("No index path for cell")
            return
        }
        
        guard let moment = moments?[indexPath.row] else {
            print("No moment for this index path")
            return
        }
        
        switch listType {
        case .myMoments(let userId):
            if userId != moment.ownerId {
                showMomentUserProfile(moment)
            }
        default:
            showMomentUserProfile(moment)
        }
    }
    
    func momentCellDidSelectMoreOptions(_ cell: MomentTableViewCell) {
        guard let indexPath = momentsTableView.indexPath(for: cell) else {
            print("No index path for cell")
            return
        }
        
        guard let moment = moments?[indexPath.row] else {
            print("No moment for this index path")
            return
        }
        
        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        //TODO: anyway we need to load users for a migrated users
        if moment.ownerId != currentUser.objectId {
            let reportAction = UIAlertAction(title: LocalizableString.Report.localizedString, style: .default, handler: { alert in
                self.showBlackLoader()
                MomentsProvider.reportMoment(moment, user: self.currentUser, completion: { (result) in
                    self.hideLoader()
                    switch result {
                        
                    case .success(_):
                        self.showAlert("", message: LocalizableString.MomentHadBeenReported.localizedString, dismissTitle: LocalizableString.Ok.localizedString, completion: nil)
                        break
                    case .failure(let error):
                        self.showAlert(LocalizableString.Error.localizedString, message: error, dismissTitle: LocalizableString.Ok.localizedString, completion: nil)
                    }
                })
            })
            alertVC.addAction(reportAction)
            
        } else {
            
            let deleteAction = UIAlertAction(title: LocalizableString.DeleteMoment.localizedString, style: .default, handler: { alert in
                
                self.showBlackLoader()
                MomentsProvider.deleteMoment(moment, user: self.currentUser, completion: { (result) in
                    
                    self.hideLoader()
                    switch result {
                        
                    case .success(_):
                        guard let index = self.moments?.index(of: moment) else {
                            print("Can't find index for the moment")
                            return
                        }
                        
                        self.moments?.remove(at: index)
                        self.momentsTableView.reloadData()
                        NotificationCenter.default.post(
                            name: Foundation.Notification.Name(rawValue: removedMomentNotification),
                            object: nil,
                            userInfo: ["moment": moment])
                        break
                    case .failure(let error):
                        self.showAlert(LocalizableString.Error.localizedString, message: error, dismissTitle: LocalizableString.Ok.localizedString, completion: nil)
                    }
                })
            })
            alertVC.addAction(deleteAction)
        }
        
        let cancelAction = UIAlertAction(title: LocalizableString.Cancel.localizedString, style: .cancel, handler: nil)
        alertVC.addAction(cancelAction)
        
        present(alertVC, animated: true, completion: nil)
    }
}
