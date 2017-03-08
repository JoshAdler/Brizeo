//
//  AboutViewController.swift
//  Brizeo
//
//  Created by Roman Bayik on 1/30/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import ChameleonFramework
import SVProgressHUD

class AboutViewController: UIViewController {
    
    // MARK: - Types
    
    struct Constants {
        static let placeholderText = LocalizableString.TypeHere.localizedString
        static let placeholderTextColor = HexColor("dbdbdb")
        static let defaultTextColor = UIColor.black
        static let cellHeightCoef: CGFloat = 68.0 / 984.0
    }
    //TODO: handle keyboard opening
    
    // MARK: - Properties
    
    @IBOutlet weak var aboutMeTextView: UITextView!
    @IBOutlet weak var passionsTableView: UITableView!
    
    @IBOutlet weak var saveButton: UIButton! {
        didSet {
            saveButton.setTitle(LocalizableString.Save.localizedString, for: .normal)
        }
    }
    @IBOutlet weak var topLabel: UILabel! {
        didSet {
            topLabel.text = LocalizableString.SelectInterests.localizedString.uppercased()
        }
    }
    @IBOutlet weak var firstLabel: UILabel! /* label for first passion */ {
        didSet {
            firstLabel.text = LocalizableString.First.localizedString
        }
    }
    @IBOutlet weak var secondLabel: UILabel! /* label for second passion */ {
        didSet {
            secondLabel.text = LocalizableString.Second.localizedString
        }
    }
    @IBOutlet weak var thirdLabel: UILabel! /* label for third passion */ {
        didSet {
            thirdLabel.text = LocalizableString.Third.localizedString
        }
    }
    
    var user: User!
    
    fileprivate var mutualFriends = [(name:String, pictureURL:String)]()
    fileprivate var selectedPassion = [String: Int]()
    fileprivate var passions: [Passion]?
    //TODO: do something with a user
    
    // MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchPassions()
//        fetchMutualFriends()

        // apply placeholder
        applyPlaceholder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UserProvider.updateUser(user: UserProvider.shared.currentUser!, completion: nil)
    }
    
    // MARK: - Actions
    
    @IBAction func onSaveButtonClicked(_ sender: UIButton!) {
        showBlackLoader()
        
        let currentUser = UserProvider.shared.currentUser!
        UserProvider.updateUser(user: currentUser) { [weak self] (result) in
            switch(result) {
            case .success(_):
                
                SVProgressHUD.showSuccess(withStatus: LocalizableString.Success.localizedString)
                break
            case .failure(let error):
                
                SVProgressHUD.showError(withStatus: error.localizedDescription)
                break
            default:
                break
            }
        }
    }
    //TODO: ask Josh about saving - in case of error? Whether we should go back?
    // MARK: - Private methods
    
    fileprivate func setSelectedPassions() {
        
        guard (passions?.count)! >= 3 else {
            print("Error: can't operate selected passions with < 3 passions")
            return
        }
        
        // init selected passions
        let ids = user.passionsIds
        if ids.count == 0 { // set default passions
            if let travelPassion = passions!.filter({ $0.displayName == "Travel" }).first {
                selectedPassion[travelPassion.objectId] = 0
                
                let leftPassions = passions!.filter({ $0.objectId != travelPassion.objectId })
                selectedPassion[leftPassions[1].objectId] = 1
                selectedPassion[leftPassions[2].objectId] = 2
            } else {
                selectedPassion[passions![0].objectId] = 0
                selectedPassion[passions![1].objectId] = 1
                selectedPassion[passions![2].objectId] = 2
            }
        } else {
            for i in 0 ..< ids.count {
                selectedPassion[ids[i]] = i
            }
            
            if selectedPassion.count < 3 {
                for i in 0 ..< (3 - selectedPassion.count) {
                    let restPassions = passions!.filter({ !Array(selectedPassion.keys).contains($0.objectId) })
                    selectedPassion[restPassions.first!.objectId] = selectedPassion.count + i
                }
            }
        }
        
        user.assignPassionIds(dict: selectedPassion)
        UserProvider.updateUser(user: user, completion: nil)
        //TODO: ask Josh about the default passions
    }
    
    fileprivate func applyPlaceholder() {
        if user.personalText.numberOfCharactersWithoutSpaces() == 0 {
            aboutMeTextView.text = Constants.placeholderText
            aboutMeTextView.textColor = Constants.placeholderTextColor
            aboutMeTextView.selectedTextRange = aboutMeTextView.textRange(from: aboutMeTextView.beginningOfDocument, to: aboutMeTextView.beginningOfDocument)
        } else {
            aboutMeTextView.text = user.personalText
        }
    }
    
    fileprivate func fetchPassions() {
        PassionsProvider.shared.retrieveAllPassions(true) { [weak self] (result) in
            if let welf = self {
                
                DispatchQueue.main.async {
                    switch result {
                    case .success(let passions):
                        
                        welf.passions = passions
                        welf.setSelectedPassions()
                        welf.passionsTableView.reloadData()
                        
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
    
    fileprivate func fetchMutualFriends() {
//        UserProvider.getMutualFriendsOfCurrentUser(User.current()!, andSecondUser: user, completion: { (result) in
//            switch result {
//            case .success(let value):
//                self.mutualFriends = value
//                self.delegate.mutualFriendsCount(value.count)
//                self.tableView.reloadSections(IndexSet(integer: Sections.mutualFriends.rawValue), with: UITableViewRowAnimation.automatic)
//            case .failure(let error):
//                self.showAlert(LocalizableString.Error.localizedString, message: error, dismissTitle: LocalizableString.Dismiss.localizedString, completion: nil)
//            }
//        })
    }
}

// MARK: - UITextViewDelegate
extension AboutViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let currentText = textView.text as NSString?
        let updatedText = currentText?.replacingCharacters(in: range, with: text)
        
        if let updatedText = updatedText, !updatedText.isEmpty  {
            if textView.textColor == Constants.placeholderTextColor && !text.isEmpty {
                textView.text = nil
                textView.textColor = Constants.defaultTextColor
            }
        } else {
            textView.text = Constants.placeholderText
            textView.textColor = Constants.placeholderTextColor
            
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            
            return false
        }
        return true
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if self.view.window != nil {
            if textView.textColor == UIColor.lightGray {
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension AboutViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return passions?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let interest = interests![indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: AboutTableViewCell.identifier, for: indexPath) as! AboutTableViewCell
        
        let passion = passions![indexPath.row]
        
        cell.delegate = self
        cell.titleLabel.text = passion.displayName
        
        if let index = selectedPassion[passion.objectId] {
            cell.selectedIndex = index
        } else {
            cell.selectedIndex = -1
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension AboutViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.cellHeightCoef * view.frame.height
    }
}

// MARK: - AboutTableViewCellDelegate
extension AboutViewController: AboutTableViewCellDelegate {
    
    func aboutTableViewCell(_ cell: AboutTableViewCell, onSelectViewClicked index: Int) {
        guard let indexPath = passionsTableView.indexPath(for: cell) else {
            assertionFailure("No index path for cell")
            return
        }
        
        var pastPassionId: String? /* get the current interest with the selected index */
        let newPassionId = passions![indexPath.row].objectId!
        
        for (passionId, _index) in selectedPassion {
            if _index == index {
                pastPassionId = passionId
                break
            }
        }
        
        if let alreadySelectedIndex = selectedPassion[newPassionId] {
            
            selectedPassion[newPassionId] = index
            
            if pastPassionId != nil {
                selectedPassion[pastPassionId!] = alreadySelectedIndex
            }
        } else {
            if pastPassionId != nil {
                selectedPassion[pastPassionId!] = nil
            }
            selectedPassion[newPassionId] = index
        }
        
        passionsTableView.reloadData()
        
        user.assignPassionIds(dict: selectedPassion)
        UserProvider.updateUser(user: user, completion: nil)
    }
}
