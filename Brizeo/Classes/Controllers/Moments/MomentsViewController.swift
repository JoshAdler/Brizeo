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
        static let cornerRadius: CGFloat = 3.0
        static let borderWidth: CGFloat = 1.0
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
            filterButton.backgroundColor = .clear
            filterButton.layer.cornerRadius = Constants.cornerRadius
            filterButton.layer.borderWidth = Constants.borderWidth
            filterButton.layer.borderColor = HexColor("dbdbdb")!.cgColor
        }
    }
    
    var listType: MomentsListType = .allMoments(userId: "0")
    var currentUser: User!// = User.current()!
    var shouldHideFilterView: Bool = false
    weak var parentDelegate: MomentsTabsViewControllerDelegate?
    
    fileprivate var paginator = PaginationHelper(pagesSize: 20)
    fileprivate var moments: [Moment]?
    fileprivate var sortedMoments: [Moment]?
    fileprivate var isNew = true
    fileprivate var badgeCount = 0
    fileprivate var interests: [Interest]?
    fileprivate var selectedInterest: Interest?
    
    // MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if currentUser == nil { // assing current user if needs
            currentUser = User.current()
        }
        
        setupTableView()
        
        momentsTableView.addInfiniteScroll { [unowned self] (tableView) in
            self.paginator.increaseCurrentPage()
            self.loadMoments(with: false)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(removeMomentNotificationReceived(_:)), name: NSNotification.Name(rawValue: removedMomentNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MomentsViewController.updateTableView), name: NSNotification.Name(rawValue: LocalizableString.SomebodyLikeYourMoment.localizedString), object: nil)
        
//        switch listType {
//        case .allMoments(_):
//            NotificationCenter.default.addObserver(self, selector: #selector(MomentsViewController.newestMomentsNotification(_:)), name: NSNotification.Name(rawValue: MomentFilterType.NewMomentForAll.rawValue), object: nil)
//            NotificationCenter.default.addObserver(self, selector: #selector(MomentsViewController.mostmomentsNotification(_:)), name: NSNotification.Name(rawValue: MomentFilterType.MostPopularForAll.rawValue), object: nil)
//            break
//        case .myMatches(_):
//            NotificationCenter.default.addObserver(self, selector: #selector(MomentsViewController.newestMomentsNotification(_:)), name: NSNotification.Name(rawValue: MomentFilterType.NewMomentForMoment.rawValue), object: nil)
//            NotificationCenter.default.addObserver(self, selector: #selector(MomentsViewController.mostmomentsNotification(_:)), name: NSNotification.Name(rawValue: MomentFilterType.MostPopularForMoment.rawValue), object: nil)
//            break
//        default:
//            NotificationCenter.default.addObserver(self, selector: #selector(MomentsViewController.newestMomentsNotification(_:)), name: NSNotification.Name(rawValue: MomentFilterType.NewMomentForMy.rawValue), object: nil)
//            NotificationCenter.default.addObserver(self, selector: #selector(MomentsViewController.mostmomentsNotification(_:)), name: NSNotification.Name(rawValue: MomentFilterType.MostPopularForMy.rawValue), object: nil)
//            break
//        }
        
        // init filter button
        initFilterButton()
        hideFilterViewIfNeeds()
        fetchInterests()
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
        
//        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: MomentFilterType.MostPopularForAll.rawValue), object: nil)
//        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: MomentFilterType.MostPopularForMoment.rawValue), object: nil)
//        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: MomentFilterType.MostPopularForMy.rawValue), object: nil)
    }
    
    @IBAction func onNewestButtonClicked(_ sender: UIButton) {
        enableRadioForButton(button: sender)
        
//        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: MomentFilterType.NewMomentForAll.rawValue), object: nil)
//        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: MomentFilterType.NewMomentForMoment.rawValue), object: nil)
//        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: MomentFilterType.NewMomentForMy.rawValue), object: nil)
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
    
    func addMoment(_ moment: Moment) {
        moments?.insert(moment, at: 0)
        momentsTableView.reloadData()
    }
    
    func refreshTableView(_ sender: UIRefreshControl) {
        sender.endRefreshing()
        resetMoments()
    }
    
    func removeMomentNotificationReceived(_ notification: Foundation.Notification) {
        guard let moment = (notification as NSNotification).userInfo?["moment"] as? Moment else {
            return
        }
        
        guard let index = moments?.index(of: moment) else {
            return
        }
        
        moments?.remove(at: index)
        momentsTableView.reloadData()
    }
    
    func newestMomentsNotification(_ notification: Foundation.Notification?) {
        if isNew == false {
            moments?.removeAll()
            self.isNew = true
            resetMoments()
        } else {
            loadMoments(with: true)
        }
    }
    
    func mostmomentsNotification(_ notification: Foundation.Notification?) {
        if isNew == true {
            moments?.removeAll()
            self.isNew = false
            resetMoments()
        } else {
            loadMoments(with: true)
        }
    }
    
    func getNotificationCount(_ moment: Moment, completionBlock: ((_ badge: Int) -> Void)?) {
        var badge = 0
        let qurey = PFQuery(className: "Notification")
        qurey.whereKey("momentId", equalTo: moment.objectId!)
        qurey.whereKey("readStaus", equalTo: false)
        qurey.findObjectsInBackground { (objects, error) in
            if error == nil {
                badge = (objects?.count)!
                completionBlock!(badge)
            }
        }
    }
    
    func checkReadStatus(_ moment: Moment) {
        moment.readStatus = true
        moment.saveInBackground()
        let query = PFQuery(className: "Notification")
        query.whereKey("momentId", equalTo: moment.objectId!)
        query.whereKey("readStaus", equalTo: false)
        query.findObjectsInBackground { (object, error) in
            if error == nil {
                self.badgeCount = (object?.count)!
                if (object?.count)! > 0 {
                    switch self.listType {
                    case .myMoments(userId: let userId):
                        if User.current()?.objectId == userId {
                            self.parentDelegate?.updateBadgeNumber(self.badgeCount)
                        }
                        break
                    default:
                        break
                    }
                    for item in object! {
                        item["readStaus"] = true
                        item.saveInBackground()
                    }
                    self.momentsTableView.reloadData()
                }
            }
        }
    }
    
    func showMomentUserProfile(_ moment: Moment) {
        if User.userIsCurrentUser(moment.user) { // show my profile
            let profileController: PersonalTabsViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.profileControllerId)!
            Helper.initialNavigationController().pushViewController(profileController, animated: true)
        } else {
            let otherPersonProfileController: OtherProfileViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.otherProfileControllerId)!
            Helper.initialNavigationController().pushViewController(otherPersonProfileController, animated: true)
        }
        GoogleAnalyticsManager.userGoToProfileFromMoment.sendEvent()
    }
    
    
    func likeMoment(_ moment: Moment) {
        
        showBlackLoader()
        
        MomentsProvider.likeMoment(moment) { (result) in
            
            self.hideLoader()
            switch result {
                
            case .success(_):
                GoogleAnalyticsManager.userHitLikeMoment.sendEvent()
                self.sendLikePushNotification(moment)
                self.momentsTableView.reloadData()
            case .failure(let error):
                self.showAlert(LocalizableString.Error.localizedString, message: error, dismissTitle: LocalizableString.Ok.localizedString, completion: nil)
                break
            }
        }
    }
    
    func sendLikePushNotification(_ moment: Moment) {
        
        let likePush = PFObject(className: "Notification")
        likePush["PushType"] = PushType.LikeMoment.localizedString
        likePush["sendUser"] = User.current()!
        likePush["receiveUser"] = moment.user
        likePush["readStaus"] = false
        likePush["momentId"] = moment.objectId
        likePush.saveEventually { (success, error) in
            if success {
                
                let query = PFInstallation.query()
                let data = [
                    "alert": LocalizableString.SomebodyLikeYourMoment.localizedStringWithArguments([(User.current()?.displayName)!]),
                    "badge": "Increment",
                    "sound": "default",
                    "push_type": PushType.LikeMoment.localizedString,
                    "user_id": (User.current()?.objectId)! as String,
                    "moment_id": moment.objectId! as String,
                    "pushId": likePush.objectId! as String]
                
                query?.whereKey("user", equalTo: moment.user)
                let queryUser = PFQuery(className: "Preferences")
                queryUser.whereKey("user", equalTo: moment.user)
                queryUser.findObjectsInBackground(block: { (objects, error) in
                    if error == nil {
                        let object = objects![0]
                        if let item = object["moments"] , item as! Bool == false {
                            
                        } else {
                            let push = PFPush()
                            push.setData(data)
                            push.setQuery(query as! PFQuery<PFInstallation>?)
                            push.sendInBackground { (status, error) in
                                if status {
                                    moment.readStatus = false
                                    moment.saveInBackground()
                                } else if error != nil {
                                    print(error!)
                                }
                            }
                        }
                    }
                })
                
            } else if error != nil {
                print(error!)
            }
        }
    }
    
    func unlikeMoment(_ moment: Moment) {
        
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
    
    // MARK: - Private methods
    
    fileprivate func fetchInterests() {
        showBlackLoader()
        InterestProvider.retrieveAllInterests { (result) in
            DispatchQueue.main.async {
                self.hideLoader()
                
                switch result {
                case .success(let interests):
                    self.interests = interests.sorted(by: {$0.displayOrder < $1.displayOrder})
                    self.initFilterButton()
                case .failure(let error):
                    self.showAlert(LocalizableString.Error.localizedString, message: error, dismissTitle: LocalizableString.Dismiss.localizedString, completion: nil)
                }
            }
        }
    }
    //TODO: retry buttons for error alerts
    fileprivate func initFilterButton() {
        guard interests != nil else {
            return
        }
        
        selectedInterest = interests!.filter({ $0.DisplayName == "Travel" }).first ?? interests?.first!
        
        // set default value
        filterButton.setTitle(selectedInterest?.DisplayName, for: .normal)
        filterButton.isEnabled = true
        
        var handlers = [() -> Void]()
        
        for i in 0 ..< interests!.count {
            handlers.append({ [weak self] () -> (Void) in
                self?.onFilterButtonClicked(i)
            })
        }
        
        let interestStrings = interests!.map({ $0.DisplayName })
        filterButton.initMenu(interestStrings, actions: handlers)
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
        
        MomentsProvider.getMomentsList(listType, sort: isNew, paginator: paginator) { [unowned self] (result) in
            
            switch result {
            case .success(let moments):
                SVProgressHUD.dismiss()
                
                if self.moments == nil {
                    self.moments = [Moment]()
                }
                
                // prefetch moments
                var urls = [URL]()
                for moment in moments {
                    if moment.imageUrl != nil {
                        urls.append(moment.imageUrl!)
                    }
                }
                SDWebImagePrefetcher.shared().prefetchURLs(urls)
                
                self.paginator.addNewElements(&self.moments!, newElements: moments)
                self.momentsTableView.reloadData()
                break
            case .failure(let error):
                SVProgressHUD.showError(withStatus: error)
                break
            }
            
            self.momentsTableView.isHidden = false
            self.momentsTableView.finishInfiniteScroll()
        }
    }
}

//protocol MomentsViewControllerDelegate {
//    func updateBadgeNumber(_ badgeCount: Int)
//}

//MARK: - UITableViewDataSource
extension MomentsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return moments?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let moment = moments![indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: MomentTableViewCell.identifier) as! MomentTableViewCell
        
        cell.delegate = self
        cell.ownerNameLabel.text = moment.user.displayName
        cell.momentDescriptionLabel.text = moment.momentDescription
        cell.numberOfLikesButton.setTitle("\(moment.numberOfLikes)", for: .normal)
        cell.likeButton.isHidden = moment.user.objectId == currentUser.objectId
        cell.setButtonHighligted(isHighligted: /*moment.likedByCurrentUser*/true)
        
        cell.momentImageView.sd_setImage(with: moment.imageUrl)
        cell.ownerLogoButton.sd_setImage(with: moment.user.profileImageUrl, for: .normal)
        
        cell.actionButton.isEnabled = true
        if moment.user.objectId != currentUser.objectId && moment.user.superUser {
            cell.actionButton.isEnabled = false
        }
        
        cell.notificationView.isHidden = true
        switch listType {
        case .myMoments(userId: let userId):
            if User.current()?.objectId == userId {
                getNotificationCount(moment, completionBlock: { (badge) in
                    if badge > 0 {
                        cell.notificationView.isHidden = false
                        cell.notificationView.text = String(format: "%d", badge)
                    }
                })
            }
        default:
            cell.notificationView.isHidden = true
        }
        
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
        
        let profileMediaType = ProfileMediaType.image(imageFile: moment.momentUploadImages, description: moment.momentDescription)
        
        let mediaController: MediaViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.mediaControllerId)!
        mediaController.isSharingEnabled = true
        mediaController.media = [profileMediaType]
        
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
        
        if moment.likedByCurrentUser {
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
        
        checkReadStatus(moment)
        
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
            if userId != moment.user.objectId {
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
        
        if moment.user.objectId != currentUser.objectId {
            let reportAction = UIAlertAction(title: LocalizableString.Report.localizedString, style: .default, handler: { alert in
                self.showBlackLoader()
                MomentsProvider.reportMoment(moment, user: User.current()!, completion: { (result) in
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
                MomentsProvider.deleteMoment(moment, user: User.current()!, completion: { (result) in
                    
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
