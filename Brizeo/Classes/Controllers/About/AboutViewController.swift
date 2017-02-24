//
//  AboutViewController.swift
//  Brizeo
//
//  Created by Roman Bayik on 1/30/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import ChameleonFramework

class AboutViewController: UIViewController {
    
    // MARK: - Types
    
    struct Constants {
        static let placeholderText = LocalizableString.TypeHere.localizedString
        static let placeholderTextColor = HexColor("dbdbdb")
        static let defaultTextColor = UIColor.black
        static let cellHeightCoef: CGFloat = 68.0 / 984.0
    }
    //TODO: handle keyboard opening
    // TODO: set default interests Travel, Foodie, Fitness
    
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
    fileprivate var interests: [String]? = ["Football", "Basketball", "Golf", "Polo", "Moto", "Kater", "Some"]//[Interest]?
    //TODO: do something with a user
    
    // MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // init selected passions
        selectedPassion = [
            interests![0]: 0,
            interests![1]: 1,
            interests![2]: 2
        ]
        
        fetchInterests()
//        fetchMutualFriends()

        // apply placeholder
        applyPlaceholder()
    }
    
    // MARK: - Actions
    
    @IBAction func onSaveButtonClicked(_ sender: UIButton!) {
        
    }
    
    // MARK: - Private methods
    
    fileprivate func applyPlaceholder() {
        if user.personalText.numberOfCharactersWithoutSpaces() == 0 {
            aboutMeTextView.text = Constants.placeholderText
            aboutMeTextView.textColor = Constants.placeholderTextColor
            aboutMeTextView.selectedTextRange = aboutMeTextView.textRange(from: aboutMeTextView.beginningOfDocument, to: aboutMeTextView.beginningOfDocument)
        } else {
            aboutMeTextView.text = user.personalText
        }
    }
    
    fileprivate func fetchInterests() {
//        InterestProvider.retrieveAllInterests { (result) in
//            switch result {
//            case .success(let interests):
//                let sortedInterests = interests.sorted(by: {$0.displayOrder < $1.displayOrder})
//                self.interests = sortedInterests.filter { self.user.interests.contains($0.objectId!) }
//                self.passionsTableView.reloadData()
//            case .failure(let error):
//                self.showAlert(LocalizableString.Error.localizedString, message: error, dismissTitle: LocalizableString.Dismiss.localizedString, completion: nil)
//            }
//        }
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
        return 7//interests?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let interest = interests![indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: AboutTableViewCell.identifier, for: indexPath) as! AboutTableViewCell
        
        let interest = interests![indexPath.row]
        
        cell.delegate = self
        //cell.titleLabel.text = interest.DisplayName
        cell.titleLabel.text = interest
        
        if let index = selectedPassion[interest] {
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
        
        var pastInterest: String = "" /* get the current interest with the selected index */
        let newInterest = interests![indexPath.row]
        
        for (interest, _index) in selectedPassion {
            if _index == index {
                pastInterest = interest
                break
            }
        }
        
        if let alreadySelectedIndex = selectedPassion[newInterest] {
            selectedPassion[newInterest] = index
            selectedPassion[pastInterest] = alreadySelectedIndex
        } else {
            selectedPassion[pastInterest] = nil
            selectedPassion[newInterest] = index
        }
        
        passionsTableView.reloadData()
    }
}

//    init(user : User) {
//        
//        self.user = user
//        super.init(nibName: String(describing: AboutViewController.self), bundle: nil)
//    }
    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        
//        if let sectionType = Sections(rawValue: (indexPath as NSIndexPath).section) {
//            
//            switch sectionType {
//            case .about:
//                let cell = tableView.dequeueReusableCell(withIdentifier: AboutTableViewCell.identifier, for: indexPath) as! AboutTableViewCell
//                cell.titleLabel.text = user.personalText
//                return cell
//            case .interests:
//                if (indexPath as NSIndexPath).row == 0 {
//                    let cell = tableView.dequeueReusableCell(withIdentifier: TitleTableViewCell.identifier, for: indexPath) as! TitleTableViewCell
//                    cell.titleLabel.text = LocalizableString.Interests.localizedString.uppercased()
//                    return cell
//                } else {
//                    let cell = tableView.dequeueReusableCell(withIdentifier: DetailsTableViewCell.identifier, for: indexPath) as! DetailsTableViewCell
//                    let interest = interests[(indexPath as NSIndexPath).row-1]
//                    cell.passionsLabel.text = interest.DisplayName
//                    return cell
//                }
//            case .mutualFriends:
//                if (indexPath as NSIndexPath).row == 0 {
//                    let cell = tableView.dequeueReusableCell(withIdentifier: TitleTableViewCell.identifier, for: indexPath) as! TitleTableViewCell
//                    cell.titleLabel.text = LocalizableString.MutualFriends.localizedString.uppercased()
//                    return cell
//                } else {
//                    let cell = tableView.dequeueReusableCell(withIdentifier: UserMatchTableViewCell.identifier, for: indexPath) as! UserMatchTableViewCell
//                    let mutualFriend = mutualFriends[(indexPath as NSIndexPath).row - 1]
//                    cell.avatarImageView.image = nil
//                    cell.nameLabel.text = mutualFriend.name
//                    if let url = URL(string: mutualFriend.pictureURL) {
//                        cell.avatarImageView.af_setImage(withURL: url)
//                    }
//                    return cell
//                }
//            }
//        }
//        let cell = tableView.dequeueReusableCell(withIdentifier: TitleTableViewCell.identifier, for: indexPath)
//        return cell
//    }

 
