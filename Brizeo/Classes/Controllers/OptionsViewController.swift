//
//  OptionsViewController.swift
//  Brizeo
//
//  Created by Roman Bayik on 3/21/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import SVProgressHUD

class OptionsViewController: BasicViewController {

    // MARK: - Types
    
    enum ContentType {
        case education
        case work
    }
    
    struct Constants {
        static let cellViewHeight: CGFloat = 54.0
    }
    
    // MARK: - Properties
    
    @IBOutlet weak var tableView: UITableView!
    var user: User!
    var type: ContentType!
    var values: [String]?
    
    // MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 55.0
        
        loadContent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if values == nil || values?.count == 0 {
            loadContent()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UserProvider.updateUser(user: user, completion: nil)
    }
    
    override func onBackButtonClicked(sender: UIBarButtonItem) {
        
        guard let navigationController = navigationController else {
            return
        }
        
        guard let tabsController = navigationController.viewControllers[navigationController.viewControllers.count - 2] as? PersonalTabsViewController else {
            return
        }
        
        let aboutController = tabsController.detailsController.aboutController
        
        aboutController?.user = user
        aboutController?.passionsTableView.reloadData()
        
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Private methods
    
    fileprivate func loadContent() {
        showBlackLoader()
        
        if type == .work {
            UserProvider.loadWorkPlaces(completion: { (result) in
                self.hideLoader()
                
                switch (result) {
                case .success(let workPlaces):
                    
                    self.values = workPlaces
                    self.tableView.reloadData()
                    
                    break
                case .failure(let error):
                    
                    SVProgressHUD.showError(withStatus: error.localizedDescription)
                    break
                default:
                    break
                }
            })
        } else { // education
            UserProvider.loadEducationPlaces(completion: { (result) in
                self.hideLoader()
                
                switch (result) {
                case .success(let educationPlaces):
                    
                    self.values = educationPlaces
                    self.tableView.reloadData()
                    
                    break
                case .failure(let error):
                    
                    SVProgressHUD.showError(withStatus: error.localizedDescription)
                    break
                default:
                    break
                }
            })
        }
    }
}

// MARK: - UITableViewDataSource
extension OptionsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return values?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SettingsCheckmarkCell = tableView.dequeueCell(withIdentifier: SettingsCheckmarkCell.identifier, for: indexPath)
        
        let value = values![indexPath.row]
        
        cell.titleLabel.text = value
        
        let selectedValue = (type == .education) ? user.studyInfo : user.workInfo
        cell.isChecked = value == selectedValue
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension OptionsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let value = values![indexPath.row]
    
        if type == .education {
            user.studyInfo = value
        } else { // work
            user.workInfo = value
        }
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension//Constants.cellViewHeight
    }
}
