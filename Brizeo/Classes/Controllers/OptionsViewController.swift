//
//  OptionsViewController.swift
//  Brizeo
//
//  Created by Roman Bayik on 3/21/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import SVProgressHUD
import Typist
import ChameleonFramework

class OptionsViewController: BasicViewController {

    // MARK: - Types
    
    enum ContentType {
        case education
        case work
    }
    
    struct Constants {
        static let cellViewHeight: CGFloat = 54.0
        static let headerHeight: CGFloat = 53.0
    }
    
    // MARK: - Properties
    
    @IBOutlet weak var tableView: UITableView!
    var user: User!
    var type: ContentType!
    var values: [String]?
    var keyboardTypist: Typist!
    
    fileprivate var activeTextField: UITextField?
    
    // MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureKeyboardBehaviour()
        
        registerHeaderViews()
        
        tableView.estimatedRowHeight = 55.0
        
        loadContent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if values == nil || values?.count == 0 {
            loadContent()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        keyboardTypist.start()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        keyboardTypist.stop()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UserProvider.updateUser(user: user, completion: nil)
    }
    
    override func onBackButtonClicked(sender: UIBarButtonItem?) {
        
        guard let navigationController = navigationController else {
            return
        }
        
        guard let tabsController = navigationController.viewControllers[navigationController.viewControllers.count - 2] as? PersonalTabsViewController else {
            return
        }
        
        // apply new text
        if let activeTextField = activeTextField, let text = activeTextField.text {
            
            if text.numberOfCharactersWithoutSpaces() > 0 {
                if type == .work {
                    user.workInfo = activeTextField.text
                } else { // education
                    user.studyInfo = activeTextField.text
                }
                tableView.reloadData()
            }
        }
        
        let aboutController = tabsController.detailsController.aboutController
        
        aboutController?.user = user
        aboutController?.passionsTableView.reloadData()
        
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Private methods
    
    fileprivate func registerHeaderViews() {
        tableView.register(UINib(nibName: SettingsBigHeaderView.nibName, bundle: nil), forHeaderFooterViewReuseIdentifier: SettingsBigHeaderView.nibName)
    }
    
    fileprivate func configureKeyboardBehaviour() {
        keyboardTypist = Typist()
        
        keyboardTypist
            .on(event: .willHide, do: { (options) in
                print("will hide options")
                UIView.animate(withDuration: options.animationDuration, delay: 0.0, options: UIViewAnimationOptions(rawValue: UInt(options.animationCurve.rawValue)), animations: {
                    
                    self.tableView.contentSize = CGSize(width: self.tableView.contentSize.width, height: self.tableView.contentSize.height - options.endFrame.height)
                }, completion: nil)
            })
            .on(event: .willShow, do: { (options) in
                print("will show options")
                UIView.animate(withDuration: options.animationDuration, delay: 0.0, options: UIViewAnimationOptions(rawValue: UInt(options.animationCurve.rawValue)), animations: {
                    
                    self.tableView.contentSize = CGSize(width: self.tableView.contentSize.width, height: self.tableView.contentSize.height + options.endFrame.height)
                }, completion: nil)
            })
            .start()
    }
    
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return values?.count ?? 0
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell: SettingsCheckmarkCell = tableView.dequeueCell(withIdentifier: SettingsCheckmarkCell.identifier, for: indexPath)
            
            let value = values![indexPath.row]
            
            cell.titleLabel.text = value
            
            let selectedValue = (type == .education) ? user.studyInfo : user.workInfo
            cell.isChecked = value == selectedValue
            
            return cell
        } else { // input cell
            let cell: OptionsInputTableViewCell = tableView.dequeueCell(withIdentifier: OptionsInputTableViewCell.identifier, for: indexPath)
            cell.textField.placeholder = type == .work ? LocalizableString.CustomWorkPlaceholder.localizedString : LocalizableString.CustomEducationPlaceholder.localizedString
            
            let selectedValue = (type == .education) ? user.studyInfo : user.workInfo
            
            if selectedValue == nil {
                cell.isChecked = true
                cell.textField.text = selectedValue
            } else if values != nil && !values!.contains(selectedValue!) {
                cell.isChecked = true
                cell.textField.text = selectedValue
            }
            else {
                cell.isChecked = false
                cell.textField.text = nil
            }
            
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension OptionsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.headerHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView: SettingsHeaderView = tableView.dequeueReusableHeaderFooterView(withIdentifier: SettingsBigHeaderView.nibName)
        
        var sectionTitle: String
        if type == .work {
            sectionTitle = section == 0 ? "My Occupation" : "General Occupation (Click Return to Add)"
        } else { //education
            sectionTitle = section == 0 ? "My School" : "General School (Click Return to Add)"
        }
        
        headerView.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: tableView.frame.width, height: Constants.headerHeight))
        headerView.contentView.backgroundColor = HexColor("224EA3")
        headerView.titleLabel.text = sectionTitle
        headerView.titleLabel.textColor = .white
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            let value = values![indexPath.row]
            
            if type == .education {
                user.studyInfo = value
            } else { // work
                user.workInfo = value
            }
            
            tableView.reloadData()
        } else { // input cell
            
            guard let cell = tableView.cellForRow(at: indexPath) as? OptionsInputTableViewCell else {
                return
            }
            
            if cell.isChecked {
            
                view.endEditing(true)
                
                if type == .education {
                   user.studyInfo = "Unknown"
                } else {
                    user.workInfo = "Unknown"
                }
                
                onBackButtonClicked(sender: nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

// MARK: - UITextFieldDelegate
extension OptionsViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if let text = textField.text {
            if text.numberOfCharactersWithoutSpaces() > 0 {
                if type == .work {
                    user.workInfo = textField.text
                } else { // education
                    user.studyInfo = textField.text
                }
                
                tableView.reloadData()
                onBackButtonClicked(sender: nil)
            }
        }
        
        return true
    }
}
