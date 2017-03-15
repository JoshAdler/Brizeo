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

let updateMomentNotification = "updateMomentNotification"

class MomentsViewController: UIViewController {

    // MARK: - Types
    
    struct Constants {
        static let backButtonColor = HexColor("1f4ba5")!
        static let cellHeightCoef: CGFloat = 564.0 / 750.0
        static let defaultFilterTitle = "All"
    }
    
    struct StoryboardIds {
        static let likesControllerId = "LikesViewController"
        static let otherProfileControllerId = "OtherProfileViewController"
        static let profileControllerId = "PersonalTabsViewController"
        static let mediaControllerId = "MediaViewController"
        static let createMomentControllerId = "CreateMomentViewController"
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
            filterButton.layer.cornerRadius = 5.0
            filterButton.layer.borderWidth = 1.0
            filterButton.layer.borderColor = HexColor("818181")!.cgColor
        }
    }
    
    var listType: MomentsListType = .allMoments
    var currentUser: User! = UserProvider.shared.currentUser!
    var shouldHideFilterView: Bool = false
    var uploadMomentHelpView: FirstEntranceMomentView?
    
    weak var parentDelegate: MomentsTabsViewControllerDelegate?
    
    fileprivate var paginator = PaginationHelper(pagesSize: 20)
    fileprivate var moments: [Moment]?
    fileprivate var sortedMoments: [Moment]?
    fileprivate var passions: [Passion]?
    fileprivate var selectedPassion: Passion?
    fileprivate var sortingFlag: MomentsSortingFlag = .newest
    
    // MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        
//        momentsTableView.addInfiniteScroll { [unowned self] (tableView) in
//            self.paginator.increaseCurrentPage()
//            self.loadMoments(with: false)
//        }

        NotificationCenter.default.addObserver(self, selector: #selector(MomentsViewController.updateTableView), name: NSNotification.Name(rawValue: updateMomentNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MomentsViewController.updateTableView), name: NSNotification.Name(rawValue: LocalizableString.SomebodyLikeYourMoment.localizedString), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setDefaults), name: NSNotification.Name(rawValue: updateMomentsListNotification), object: nil)
        
        fetchPassions()
        initFilterButton()
        hideFilterViewIfNeeds()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        let count = moments?.count ?? 0
        if count == 0 {
            momentsTableView.isHidden = true
            loadMoments(with: true, removeOldMoments: false)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        LocationManager.shared.checkAccessStatus()
        
        presentSharedContentIfNeeds()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Actions
    
//    func onFilterButtonClicked(_ index: Int) {
//        if index == 0 { // no filtering
//            selectedPassion = nil
//        } else {
//            selectedPassion = passions?[index - 1]
//        }
//        
//        resetMoments()
//    }
    
    @IBAction func onFilterButtonClicked(_ sender: UIButton) {

        guard passions != nil && passions!.count > 0 else {
            print("No interests")
            return
        }
        
        let alertController = UIAlertController(title: nil, message: LocalizableString.SelectFitlerPassion.localizedString, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        // add action for case "All"
        alertController.addAction(UIAlertAction(title: Constants.defaultFilterTitle, style: .default, handler: { (action) in
            
            self.selectedPassion = nil
            sender.setTitle(action.title, for: .normal)
            
            self.resetMoments()
        }))
        
        for passion in passions! {
            alertController.addAction(UIAlertAction(title: passion.displayName, style: .default, handler: { (action) in
                
                self.selectedPassion = self.passions!.filter({ $0.displayName == action.title }).first
                sender.setTitle(action.title, for: .normal)
                
                self.resetMoments()
            }))
        }
        
        alertController.addAction(UIAlertAction(title: LocalizableString.Cancel.localizedString, style: UIAlertActionStyle.cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func onCreateButtonClicked(_ sender: UIButton) {
        parentDelegate?.onCreateMoment()
    }
    
    @IBAction func onPopularButtonClicked(_ sender: UIButton) {
        enableRadioForButton(button: sender)
        
        sortingFlag = MomentsSortingFlag(with: sender.tag)
        resetMoments()
    }
    
    @IBAction func onNewestButtonClicked(_ sender: UIButton) {
        enableRadioForButton(button: sender)
        
        sortingFlag = MomentsSortingFlag(with: sender.tag)
        resetMoments()
    }
    
    // MARK: - Public methods
    
    func setDefaults() {
        sortingFlag = .newest
        enableRadioForButton(button: newestButton)
        
        updateTableView()
    }
    
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
    
    func hideHelpView(isHidden: Bool) {
        if uploadMomentHelpView == nil {
            uploadMomentHelpView = FirstEntranceMomentView.loadFromNib()
            uploadMomentHelpView?.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
            uploadMomentHelpView?.isHidden = true
            uploadMomentHelpView?.delegate = self
            
            // count distances 
            let globalPoint = addMomentButton.superview!.convert(addMomentButton.frame.origin, to: AppDelegate.shared().window)
            uploadMomentHelpView!.rightDistance = UIScreen.main.bounds.width - globalPoint.x - addMomentButton.frame.width
            uploadMomentHelpView!.topDistance = globalPoint.y /*+ 44.0 +Helper.carbonViewHeight()*/ /* navigation bar */
            
            AppDelegate.shared().window?.addSubview(uploadMomentHelpView!)
        }
        
        uploadMomentHelpView?.isHidden = isHidden
    }
    
    func goToPersonalProfile(animated: Bool) {
        let profileController: PersonalTabsViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.profileControllerId)!
        //Helper.initialNavigationController().pushViewController(profileController, animated: animated)
        Helper.initialNavigationController().pushViewController(profileController, animated: animated)
    }
    
    // MARK: - Private methods
    
    fileprivate func presentSharedContentIfNeeds() {
        // check whether we need to present user or moment
        
        if let userId = BranchProvider.userIdToPresent() {
            showUserProfile(with: userId, orMoment: nil)
        }
        
        if let momentId = BranchProvider.momentIdToPresent() {
            loadAndShowMoment(with: momentId)
        }
    }
    
    fileprivate func showUserProfile(with userId: String?, orMoment moment: Moment?) {
        let userIdentifier = userId ?? moment?.ownerId ?? "-1"
        
        if userIdentifier == currentUser.objectId { // show my profile
            goToPersonalProfile(animated: true)
        } else {
            let otherPersonProfileController: OtherProfileViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.otherProfileControllerId)!
            otherPersonProfileController.user = moment?.user
            otherPersonProfileController.userId = userIdentifier
//            Helper.initialNavigationController().pushViewController(otherPersonProfileController, animated: true)
            navigationController?.pushViewController(otherPersonProfileController, animated: true)
        }
    }
    
    
    fileprivate func likeMoment(_ moment: Moment) {
        showBlackLoader()
        
        MomentsProvider.like(momentToLike: moment) { (result) in
            self.hideLoader()
            
            switch result {
            case .success(let updatedMoment):
                GoogleAnalyticsManager.userHitLikeMoment.sendEvent()
                
                if let index = self.moments?.index(of: moment) {
                    self.moments?[index] = updatedMoment
                    
                    self.momentsTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                }
            case .failure(let error):
                self.showAlert(LocalizableString.Error.localizedString, message: error.localizedDescription, dismissTitle: LocalizableString.Ok.localizedString, completion: nil)
                break
            default:
                break
            }
        }
    }
    
    fileprivate func unlikeMoment(_ moment: Moment) {
        showBlackLoader()
        
        MomentsProvider.unlike(momentToUnlike: moment) { (result) in
            self.hideLoader()
        
            switch result {
            case .success(let updatedMoment):
                
                if let index = self.moments?.index(of: moment) {
                    self.moments?[index] = updatedMoment
                    
                    self.momentsTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                }
            case .failure(let error):
                self.showAlert(LocalizableString.Error.localizedString, message: error.localizedDescription, dismissTitle: LocalizableString.Ok.localizedString, completion: nil)
                break
            default:
                break
            }
        }
    }
    
    fileprivate func fetchPassions() {
        PassionsProvider.shared.retrieveAllPassions(true) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let passions):
                    self.passions = passions
                    self.initFilterButton()
                case .failure(let error):
                    self.showAlert(LocalizableString.Error.localizedString, message: error.localizedDescription, dismissTitle: LocalizableString.Dismiss.localizedString, completion: nil)
                default:
                    break
                }
            }
        }
    }
    
    fileprivate func initFilterButton() {
        guard passions != nil else {
            return
        }
        
        // set default value
        filterButton.setTitle(Constants.defaultFilterTitle, for: .normal)
        filterButton.isEnabled = true
        
//        var handlers = [() -> Void]()
//        
//        // set 0 handler for "All" filter
//        handlers.append({ [weak self] () -> (Void) in
//            self?.onFilterButtonClicked(0)
//        })
//        
//        for i in 1 ..< passions!.count + 1 {
//            handlers.append({ [weak self] () -> (Void) in
//                self?.onFilterButtonClicked(i)
//            })
//        }
        
//        let passionStrings = [Constants.defaultFilterTitle] + passions!.map({ $0.displayName })
//        filterButton.initMenu(passionStrings, actions: handlers)
    }
    
    fileprivate func enableRadioForButton(button: UIButton) {
        newestButton.isSelected = button == newestButton
        popularButton.isSelected = button == popularButton
    }
    
    fileprivate func setupTableView() {
        momentsTableView.prefetchDataSource = self
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(MomentsViewController.refreshTableView), for: .valueChanged)
        
        momentsTableView.rowHeight = UITableViewAutomaticDimension
        momentsTableView.estimatedRowHeight = 400
        momentsTableView.tableFooterView = UIView()
        momentsTableView.addSubview(refreshControl)
    }
    
    fileprivate func resetMoments() {
        paginator.resetPages()
        loadMoments(with: true, removeOldMoments: true)
    }
    
    fileprivate func loadMoments(with centerLoading: Bool, removeOldMoments: Bool) {
        if centerLoading {
            SVProgressHUD.show()
        }
        
        MomentsProvider.getMoments(with: listType, sortingFlag: sortingFlag, filterPassion: selectedPassion, paginator: paginator) { [unowned self] (result) in
            
            switch result {
            case .success(let newMoments):
                SVProgressHUD.dismiss()
                
                if removeOldMoments {
                    self.moments = [Moment]()
                }
                
                if self.moments == nil {
                    self.moments = [Moment]()
                }
                
                // prefetch moments
                MomentsProvider.preloadMomentPictures(isFirstTime: true, moments: newMoments)
                
                self.paginator.addNewElements(&self.moments!, newElements: newMoments)
                self.momentsTableView.reloadData()
                break
            case .failure(let error):
                SVProgressHUD.showError(withStatus: error.localizedDescription)
                break
            default:
                break
            }
            
            self.momentsTableView.isHidden = false
            self.momentsTableView.finishInfiniteScroll()
        }
    }
    
    fileprivate func loadAndShowMoment(with momentId: String) {
        showBlackLoader()
        
        MomentsProvider.getMoment(with: momentId) { (result) in
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
        
        Helper.initialNavigationController().pushViewController(mediaController, animated: true)
    }
    
    fileprivate func presentErrorAlert(momentId: String, message: String?) {
        let alert = UIAlertController(title: LocalizableString.Error.localizedString, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: LocalizableString.TryAgain.localizedString, style: .default, handler: { (action) in
            self.loadAndShowMoment(with: momentId)
        }))
        
        alert.addAction(UIAlertAction(title: LocalizableString.Dismiss.localizedString, style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
}

//MARK: - UITableViewDataSource
extension MomentsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return moments?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let index = indexPath.row + 10
        
        guard moments != nil, index < moments!.count else {
            return
        }
        
        let moment = moments![index]
        MomentsProvider.preloadMomentPictures(isFirstTime: false, moments: [moment])
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let moment = moments![indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: MomentTableViewCell.identifier) as! MomentTableViewCell
        
        cell.delegate = self
        cell.ownerNameLabel.text = moment.user.displayName
        cell.momentDescriptionLabel.text = moment.shortCapture
        cell.numberOfLikesButton.setTitle("\(moment.likesCount)", for: .normal)
        cell.likeButton.isHidden = moment.ownerId == currentUser.objectId
        cell.setButtonHighligted(isHighligted: moment.isLikedByCurrentUser)
        cell.actionButton.isEnabled = !moment.user.isSuperUser
        cell.playImageView.isHidden = !moment.hasVideo
        
        cell.momentImageView.sd_setImage(with: moment.imageUrl)
        cell.ownerLogoButton.sd_setImage(with: moment.user.profileUrl, for: .normal)
        
        cell.notificationView.isHidden = true
        
        // set locations for the moment
        cell.locationLabel.text = ""
        
        if moment.hasLocation {
            LocationManager.shared.getMomentLocationStringForLocation(moment.location!, moment.objectId, completion: { [weak cell, weak self] (locationStr, momentId) in
                if cell != nil && self != nil {
                    guard let indexPath = tableView.indexPath(for: cell!) else {
                        return
                    }
                    
                    if let moments = self!.moments, moments[indexPath.row].objectId == momentId {
                        cell!.locationLabel.text = locationStr
                    }
                }
            })
        }
        
        
        return cell
    }
}

// MARK: - UITableViewDataSourcePrefetching
extension MomentsViewController: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        guard moments != nil else {
            return
        }
        
        let prefetchMoments = indexPaths.map({ moments![$0.row] })
        MomentsProvider.preloadMomentPictures(isFirstTime: false, moments: prefetchMoments)
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
        
        show(moment: moment)
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

        let likersController: LikesViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.likesControllerId)!
        likersController.moment = moment
        
        //Helper.initialNavigationController().pushViewController(likersController, animated: true)
        navigationController?.pushViewController(likersController, animated: true)
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
        
        showUserProfile(with: moment.ownerId, orMoment: moment)
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
        
        if moment.ownerId != currentUser.objectId {
            alertVC.addAction(UIAlertAction(title: LocalizableString.Report.localizedString, style: .default, handler: { alert in
                self.showBlackLoader()
                
                MomentsProvider.report(moment: moment, completion: { (result) in
                    self.hideLoader()
                    
                    switch result {
                    case .success(_):
                        self.showAlert("", message: LocalizableString.MomentHadBeenReported.localizedString, dismissTitle: LocalizableString.Ok.localizedString, completion: nil)
                        break
                    case .failure(let error):
                        self.showAlert(LocalizableString.Error.localizedString, message: error.localizedDescription, dismissTitle: LocalizableString.Ok.localizedString, completion: nil)
                    default:
                        break
                    }
                })
            }))
        } else {
            alertVC.addAction(UIAlertAction(title: LocalizableString.DeleteMoment.localizedString, style: .default, handler: { alert in
                
                let confirmationView: ConfirmationView = ConfirmationView.loadFromNib()
                confirmationView.title = LocalizableString.ConfirmationDeleteMomentText.localizedString
                confirmationView.present(on: Helper.initialNavigationController().view, confirmAction: {
                    self.showBlackLoader()
                    
                    MomentsProvider.delete(moment: moment, completion: { (result) in
                        self.hideLoader()
                        
                        switch result {
                        case .success(_):
                            guard let index = self.moments!.index(of: moment) else {
                                print("Can't find index for the moment")
                                return
                            }
                            
                            self.moments?.remove(at: index)
                            self.momentsTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                            
                            Helper.sendNotification(with: updateMomentNotification, object: nil, dict: ["moment": moment])
                            break
                        case .failure(let error):
                            self.showAlert(LocalizableString.Error.localizedString, message: error.localizedDescription, dismissTitle: LocalizableString.Ok.localizedString, completion: nil)
                        default:
                            break
                        }
                    })
                }, declineAction: nil)
                
            }))
            
            alertVC.addAction(UIAlertAction(title: LocalizableString.EditMoment.localizedString, style: .default, handler: { alert in
                
                let createMomentController: CreateMomentViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.createMomentControllerId)!
                createMomentController.moment = moment
                
                Helper.initialNavigationController().pushViewController(createMomentController, animated: true)
            }))
        }
        
        alertVC.addAction(UIAlertAction(title: LocalizableString.Cancel.localizedString, style: .cancel, handler: nil))
        
        present(alertVC, animated: true, completion: nil)
    }
}

// MARK: - FirstEntranceMomentViewDelegate
extension MomentsViewController: FirstEntranceMomentViewDelegate {
    
    func momentView(view: FirstEntranceMomentView, didClickedOnCreate button: UIButton) {
        hideHelpView(isHidden: true)
        onCreateButtonClicked(addMomentButton)
    }
}
