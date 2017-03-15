//
//  TripSearchBar.swift
//  Brizeo
//
//  Created by Roman Bayik on 3/15/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import ChameleonFramework

class TripSearchBar: UISearchBar {
    
    // MARK: - Types
    
    struct Constants {
        static let sideMargin: CGFloat = 37.0
        static let height: CGFloat = 28.0
    }
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.frame = frame
        
        isTranslucent = false
        
        barTintColor = HexColor("e1e1e1")!
        tintColor = HexColor("5c6a76")!
        setImage(#imageLiteral(resourceName: "ic_trip_search"), for: .search, state: .normal)
        
        let textField = UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self])
        textField.defaultTextAttributes = [
            NSFontAttributeName: UIFont(name: "SourceSansPro-SemiboldIt"/*"SourceSansPro-Semibold"*/, size: 14)!
        ]
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    // MARK: - Private methods
    
    fileprivate func indexOfSearchFieldInSubviews() -> Int! {
        var index: Int!
        let searchBarView = subviews[0] 
        
        for i in 0 ..< searchBarView.subviews.count {
            if searchBarView.subviews[i].isKind(of: UITextField.self) {
                index = i
                break
            }
        }
        
        return index
    }
    
    // MARK: - Override methods
    
    override func draw(_ rect: CGRect) {
        // Find the index of the search field in the search bar subviews.
        if let index = indexOfSearchFieldInSubviews() {
            // Access the search fieldq
            let searchField: UITextField = (subviews[0]).subviews[index] as! UITextField
            
            // Set its frame.
            searchField.frame = CGRect(x: Constants.sideMargin, y: (frame.height - Constants.height) / 2.0, width: frame.width - Constants.sideMargin * 2.0, height: Constants.height)
            
            // Set the background color of the search field.
            searchField.backgroundColor = .white
            searchField.layer.borderWidth = 1.0
            searchField.layer.borderColor = HexColor("c0c0c0")!.cgColor
            searchField.layer.cornerRadius = 5.0
            searchField.clipsToBounds = true
        }
        
        super.draw(rect)
    }
}
