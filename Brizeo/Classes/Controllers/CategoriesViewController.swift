//
//  CategoriesViewController.swift
//  Brizeo
//
//  Created by Roman Bayik on 7/13/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import ChameleonFramework

class CategoriesViewController: BasicViewController {

    // MARK: - Types
    
    struct Constants {
        static let defaultTextColor = UIColor.black
        static let headerViewHeight: CGFloat = 54.0
        static let passionCellHeight: CGFloat = 52.0
    }
    
    struct StoryboardIds {
        static let headerViewId = "SettingsBigHeaderView"
    }
    
    // MARK: - Properties
    
    @IBOutlet weak var tableView: UITableView!
    
    var user: User!
    fileprivate var passions: [Passion]?
    
    // MARK: - Controller
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 80.0
        
        registerHeaderViews()
        fetchPassions()
    }
    
    override func shouldPlaceInviteButton() -> Bool {
        return false
    }
    
    // MARK: - Private methods
    
    fileprivate func fetchPassions() {
        PassionsProvider.shared.retrieveAllPassions(true) { [weak self] (result) in
            if let welf = self {
                
                DispatchQueue.main.async {
                    switch result {
                    case .success(let passions):
                        
                        welf.passions = passions
                        welf.tableView.reloadData()
                        
                        break
                    case .failure(let error):
                        
                        welf.showAlert(LocalizableString.Error.localizedString, message: error.localizedDescription, dismissTitle: LocalizableString.Dismiss.localizedString) {
                            welf.fetchPassions()
                        }
                        
                        break
                    default:
                        break
                    }
                }
            }
        }
    }
    
    fileprivate func registerHeaderViews() {
        tableView.register(UINib(nibName: SettingsBigHeaderView.nibName, bundle: nil), forHeaderFooterViewReuseIdentifier: SettingsBigHeaderView.nibName)
    }
    
    fileprivate func selectPassion(_ passion: Passion) {
        
        if user.passionsIds.count < Configurations.General.requiredMinPassionsCount {
            user.passionsIds.append(passion.objectId)
            
            tableView.reloadData()
        } else {
            
            // show dialog box
            let toManyPassionsView: NoDescriptionView = NoDescriptionView.loadFromNib()
            toManyPassionsView.present(on: Helper.initialNavigationController().view)
            return
        }
    }
    
    fileprivate func unselectPassion(_ passion: Passion) {
        
        if let index = user.passionsIds.index(of: passion.objectId) {
            user.passionsIds.remove(at: index)
            
            tableView.reloadData()
        }
    }
    
    fileprivate func clickedOnPassion(_ passion: Passion) {
        
        if user.passionsIds.contains(passion.objectId) {
            unselectPassion(passion)
        } else {
            selectPassion(passion)
        }
        
        navigationItem.leftBarButtonItem?.isEnabled = user.passionsIds.count == Configurations.General.requiredMinPassionsCount
        
        // notify about changes
        Helper.sendNotification(with: searchLocationChangedNotification, object: nil, dict: nil)
    }
}

// MARK: - UITableViewDataSource
extension CategoriesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        guard passions != nil else {
            return 1
        }
        
        let cellCount = (CGFloat(passions!.count) / 2.0).rounded(.up)
        return Int(cellCount) + 1 /* text cell at the top */
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 { // text cell
            let cell: CategoriesTextTableViewCell = tableView.dequeueCell(withIdentifier: CategoriesTextTableViewCell.identifier, for: indexPath)
            
            cell.titleLabel.text = LocalizableString.CategoriesIntroText.localizedString
            
            return cell
        } else { // passion cell
            let cell: CategoriesPassionTableViewCell = tableView.dequeueCell(withIdentifier: CategoriesPassionTableViewCell.identifier, for: indexPath)
            
            let passionIndex = ((indexPath.row - 1) * 2)
            let leftPassion = passions![passionIndex]
            let rightPassion = passions![passionIndex + 1]
            
            cell.delegate = self
            cell.setLeftPassion(passion: leftPassion)
            cell.setRightPassion(passion: rightPassion)
            cell.setIsLeftSelected(user.passionsIds.contains(leftPassion.objectId))
            cell.setIsRightSelected(user.passionsIds.contains(rightPassion.objectId))
            
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension CategoriesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 0 { // text cell
            return UITableViewAutomaticDimension
        } else {
            return Constants.passionCellHeight
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.headerViewHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView: SettingsHeaderView = tableView.dequeueReusableHeaderFooterView(withIdentifier: StoryboardIds.headerViewId)
        
        headerView.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: tableView.frame.width, height: Constants.headerViewHeight))
        headerView.titleLabel.text = LocalizableString.SelectCategories.localizedString.uppercased()
        headerView.titleLabel.textColor = HexColor("5f5f5f")!
        return headerView
    }
}

// MARK: - CategoriesPassionTableViewCellDelegate
extension CategoriesViewController: CategoriesPassionTableViewCellDelegate {
    
    func categoryCell(cell: CategoriesPassionTableViewCell, didClickedOnLeft button: UIButton) {
        
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        let passionIndex = ((indexPath.row - 1) * 2)
        let selectedPassion = passions![passionIndex]
        
        clickedOnPassion(selectedPassion)
    }
    
    func categoryCell(cell: CategoriesPassionTableViewCell, didClickedOnRight button: UIButton) {
        
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        let passionIndex = ((indexPath.row - 1) * 2)
        let selectedPassion = passions![passionIndex + 1]
        
        clickedOnPassion(selectedPassion)
    }
}
