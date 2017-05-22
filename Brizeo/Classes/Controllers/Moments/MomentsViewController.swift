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
import ChameleonFramework
import SDWebImage

let updateMomentNotification = "updateMomentNotification"

class MomentsViewController: UIViewController {

    // MARK: - Types
    
    struct Constants {
        static let backButtonColor = HexColor("1f4ba5")!
        static let cellHeightCoef: CGFloat = 675.0 / 750.0
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
    @IBOutlet weak fileprivate var newestButton: UIButton! {
        didSet {
            newestButton.titleLabel?.numberOfLines = 1
            newestButton.titleLabel?.adjustsFontSizeToFitWidth = true
            newestButton.titleLabel?.lineBreakMode = NSLineBreakMode.byClipping
        }
    }
    @IBOutlet weak fileprivate var popularButton: UIButton! {
        didSet {
            popularButton.titleLabel?.numberOfLines = 1
            popularButton.titleLabel?.adjustsFontSizeToFitWidth = true
            popularButton.titleLabel?.lineBreakMode = NSLineBreakMode.byClipping
        }
    }
    @IBOutlet weak fileprivate var filterButton: DropMenuButton! {
        didSet {
            filterButton.layer.cornerRadius = 5.0
            filterButton.layer.borderWidth = 1.0
            filterButton.layer.borderColor = HexColor("818181")!.cgColor
            filterButton.titleLabel?.numberOfLines = 1
            filterButton.titleLabel?.adjustsFontSizeToFitWidth = true
            filterButton.titleLabel?.lineBreakMode = NSLineBreakMode.byClipping
        }
    }
    
    var listType: MomentsListType = .allMoments
    var currentUser: User! = UserProvider.shared.currentUser!
    var shouldHideFilterView: Bool = false
    var uploadMomentHelpView: FirstEntranceMomentView?
    
    weak var parentDelegate: MomentsTabsViewControllerDelegate?
    
    fileprivate var refreshControl: UIRefreshControl?
    fileprivate var paginator = PaginationHelper(pagesSize: 30)
    fileprivate var moments: [Moment]?
    fileprivate var sortedMoments: [Moment]?
    fileprivate var passions: [Passion]?
    fileprivate var selectedPassion: Passion?
    fileprivate var sortingFlag: MomentsSortingFlag = .newest
    
    // MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        addInfinityScroll()

        NotificationCenter.default.addObserver(self, selector: #selector(MomentsViewController.updateTableView), name: NSNotification.Name(rawValue: updateMomentNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MomentsViewController.updateTableView), name: NSNotification.Name(rawValue: LocalizableString.SomebodyLikeYourMoment.localizedString), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setDefaults), name: NSNotification.Name(rawValue: updateMomentsListNotification), object: nil)
        
        fetchPassions()
        initFilterButton()
        hideFilterViewIfNeeds()
        
        LocationManager.shared.checkAccessStatus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        currentUser = UserProvider.shared.currentUser!
        
        let count = moments?.count ?? 0
        if count == 0 {
            momentsTableView.isHidden = true
            loadMoments(with: true, removeOldMoments: false)
        } else {
            
            for indexPath in momentsTableView.indexPathsForVisibleRows ?? [] {
                if moments![indexPath.row].user.objectId == currentUser.objectId {
                    moments![indexPath.row].user = currentUser
                }
            }
            
            momentsTableView.reloadData()
        }
        
        tabBarController?.tabBar.isHidden = false
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Actions
    
    @IBAction func onFilterButtonClicked(_ sender: UIButton) {

        guard passions != nil && passions!.count > 0 else {
            print("No interests")
            return
        }
        
        let alertController = UIAlertController(title: nil, message: LocalizableString.SelectFitlerPassion.localizedString, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        // add action for case "All"
        alertController.addAction(UIAlertAction(title: Constants.defaultFilterTitle, style: .default, handler: { (action) in
            
            self.selectedPassion = nil
            self.addInfinityScroll()
            sender.setTitle(action.title, for: .normal)
            
            self.resetMoments()
        }))
        
        for passion in passions! {
            alertController.addAction(UIAlertAction(title: passion.displayName, style: .default, handler: { (action) in
                
                self.momentsTableView.removeInfiniteScroll()
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
        paginator.resetPages()
        loadMoments(with: false, removeOldMoments: true)
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
        Helper.currentTabNavigationController()?.pushViewController(profileController, animated: animated)
    }
    
    // MARK: - Private methods
    
    fileprivate func addInfinityScroll() {
        
        /* Add pagination only for all moments */
        
        switch listType {
        case .allMoments:

            momentsTableView.addInfiniteScroll { [unowned self] (tableView) in
                self.paginator.increaseCurrentPage()
                self.loadMoments(with: false, removeOldMoments: false)
            }
        default:
            break
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

            navigationController?.pushViewController(otherPersonProfileController, animated: true)
            
            LocalyticsProvider.userGoProfileFromMoments()
        }
    }
    
    fileprivate func likeMoment(_ moment: Moment) {
        showBlackLoader()
        
        MomentsProvider.like(momentToLike: moment) { (result) in
            self.hideLoader()
            
            switch result {
            case .success(let updatedMoment):
                LocalyticsProvider.trackMomentLike(momentId: moment.objectId)
                
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
    }
    
    fileprivate func enableRadioForButton(button: UIButton) {
        newestButton.isSelected = button == newestButton
        popularButton.isSelected = button == popularButton
    }
    
    fileprivate func setupTableView() {
        momentsTableView.prefetchDataSource = self
        
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(MomentsViewController.refreshTableView), for: .valueChanged)
        
        momentsTableView.rowHeight = UITableViewAutomaticDimension
        momentsTableView.estimatedRowHeight = 400
        momentsTableView.tableFooterView = UIView()
        momentsTableView.addSubview(refreshControl!)
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
                
                self.refreshControl?.endRefreshing()
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
    
    fileprivate func show(moment: Moment) {
        let mediaController: MediaViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.mediaControllerId)!
        mediaController.isSharingEnabled = true
        mediaController.moment = moment
        
        let navigation = navigationController ?? Helper.currentTabNavigationController()
        navigation?.pushViewController(mediaController, animated: true)
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
        cell.ownerNameLabel.text = moment.user.shortName/*displayName*/
        cell.momentDescriptionLabel.text = moment.shortCapture
        cell.numberOfLikesButton.setTitle("\(moment.likesCount)", for: .normal)
        cell.likeButton.isHidden = moment.ownerId == currentUser.objectId
        cell.setButtonHighligted(isHighligted: moment.isLikedByCurrentUser)
        cell.actionButton.isEnabled = !moment.user.isSuperUser || (moment.user.isSuperUser && currentUser.isSuperUser)
        cell.playImageView.isHidden = !moment.hasVideo
        
        if SDWebImageManager.shared().cachedImageExists(for: moment.imageUrl) {
            cell.momentImageView.alpha = 1.0
            cell.momentImageView.sd_setImage(with: moment.imageUrl)
        } else {
            cell.momentImageView.alpha = 0.0
            cell.momentImageView.sd_setImage(with: moment.imageUrl, completed: { [weak cell, weak self] (image, error, cacheType, url) in
                
                if cell != nil && self != nil {
                    guard let indexPath = tableView.indexPath(for: cell!) else { return }
                    
                    if self!.moments![indexPath.row].imageUrl != url { return }
                    
                    UIView.animate(withDuration: 0.2, animations: { 
                        cell?.momentImageView.alpha = 1.0
                    })
                }
            })
        }

        cell.ownerLogoImageView.sd_setImage(with: moment.user.profileUrl)
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
        return 500.0
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
        
        Helper.currentTabNavigationController()?.pushViewController(likersController, animated: true)
        
        LocalyticsProvider.userViewLikers()
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
                Helper.currentTabNavigationController()?.pushViewController(createMomentController, animated: true)
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
