//
//  OtherPersonAboutInfoTableViewCell.swift
//  Brizeo
//
//  Created by Roman Bayik on 2/1/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit

class OtherPersonAboutInfoTableViewCell: UITableViewCell {

    // MARK: - Types
    
    struct Constants {
        static let defaultColor = UIColor.black
        static let defaultFontSize: CGFloat = 11.0
    }
    
    // MARK: - Properties
    
    @IBOutlet weak var interestLabel: UILabel!
    @IBOutlet weak var educationLabel: UILabel!
    @IBOutlet weak var workLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var friendsLabel: UILabel!
    
    // MARK: - Public methods
    
    func applyUser(user: User) {
        // passions
        PassionsProvider.shared.retrieveAllPassions(true) { [weak self] (result) in
            if self != nil {
                switch result {
                case .success(let passions):
                    var passionText = ""
                    for id in user.passionsIds {
                        if let passion = passions.filter({ $0.objectId == id }).first {
                            passionText.append("\(passion.displayName.capitalized), ")
                        }
                    }
                    
                    let endIndex = passionText.index(passionText.endIndex, offsetBy: -2)
                    passionText = passionText.substring(to: endIndex)
                    self?.interestLabel.text = passionText
                    break
                case .failure(let message):
                    self?.interestLabel.text = nil
                    break
                }
            }
        }
        
        // study
        educationLabel.text = user.studyInfo
        
        // work
        workLabel.text = user.workInfo
    }
    
    func applyLocationWithUser(user: User, locationString: String?) {
        let locationAttributes = [NSForegroundColorAttributeName: Constants.defaultColor, NSFontAttributeName: UIFont(name: "SourceSansPro-Regular", size: Constants.defaultFontSize)]
        let distanceAttributes = [NSForegroundColorAttributeName: Constants.defaultColor, NSFontAttributeName: UIFont(name: "SourceSansPro-Bold", size: Constants.defaultFontSize)]
        
        let partOneString = locationString ?? ""
        let partOne = NSMutableAttributedString(string: partOneString, attributes: locationAttributes)

        var distanceString = ""
        if UserProvider.shared.currentUser!.hasLocation {
            if let distance = LocationManager.countDistanceInString(from: user, to: UserProvider.shared.currentUser!) {
                distanceString = distance
            }
        }
        
        let partTwo = NSMutableAttributedString(string: "\(partOneString.numberOfCharactersWithoutSpaces() > 0 ? "\n" : "") \(distanceString)", attributes: distanceAttributes)
        
        let combination = NSMutableAttributedString()
        
        combination.append(partOne)
        combination.append(partTwo)
    
        locationLabel.attributedText = combination
    }
}
