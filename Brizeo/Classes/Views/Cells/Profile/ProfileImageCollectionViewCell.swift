//
//  ProfileImageCollectionViewCell.swift
//  Brizeo
//
//  Created by Arturo on 4/29/16.
//  Copyright © 2016 Kogi Mobile. All rights reserved.
//

import UIKit

protocol ProfileImageCollectionViewCellDelegate {
    func profileImageCollectionView(_ cell: ProfileImageCollectionViewCell, onDeleteButtonClicked button: UIButton)
}

class ProfileImageCollectionViewCell: UICollectionViewCell {

    // MARK: - Properties
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet fileprivate weak var deleteButton: UIButton!
    @IBOutlet fileprivate weak var editIconImageView: UIImageView!
    var delegate : ProfileImageCollectionViewCellDelegate?
    
    var isDeleteButtonHidden: Bool {
        get {
            return deleteButton.isHidden
        }
        set {
            deleteButton.isHidden = newValue
            editIconImageView.isHidden = newValue
        }
    }
    
    // MARK: - Actions
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        delegate?.profileImageCollectionView(self, onDeleteButtonClicked: sender)
    }
}
