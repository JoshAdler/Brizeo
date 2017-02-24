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
        // interest
        var interestText = ""
        for interest in user.interests {
            interestText.append("\(interest.capitalized), ")
        }
        
        let endIndex = interestText.index(interestText.endIndex, offsetBy: -2)
        interestText = interestText.substring(to: endIndex)
        interestLabel.text = interestText
        
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
        if let currentLocation = /*User.current()!*/User.test().location, let distance = user.getDistanceString(currentLocation) {
            distanceString = distance
        }
        let partTwo = NSMutableAttributedString(string: "\(partOneString.numberOfCharactersWithoutSpaces() > 0 ? "\n" : "") \(distanceString)", attributes: distanceAttributes)
        
        let combination = NSMutableAttributedString()
        
        combination.append(partOne)
        combination.append(partTwo)
    
        locationLabel.attributedText = combination
    }
}
