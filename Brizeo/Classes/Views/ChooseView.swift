//
//  ChooseView.swift
//  Brizeo
//
//  Created by Roman Bayik on 2/13/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit

class ChooseView: UIView {

    // MARK: - Types
    
    enum Items: Int {
        case sms = 0
        case messanger
        case whatsapp
        case email
        case twitter
        
        var data: (String, UIImage) {
            switch self {
            case .sms:
                return (LocalizableString.SMSShare.localizedString, #imageLiteral(resourceName: "ic_share_message"))
            case .messanger:
                return (LocalizableString.MessangerShare.localizedString, #imageLiteral(resourceName: "ic_share_facebook"))
            case .whatsapp:
                return (LocalizableString.WhatsappShare.localizedString, #imageLiteral(resourceName: "ic_share_whatsapp"))
            case .email:
                return (LocalizableString.EmailShare.localizedString, #imageLiteral(resourceName: "ic_share_email"))
            case .twitter:
                return (LocalizableString.TwitterShare.localizedString, #imageLiteral(resourceName: "ic_share_twitter"))
            }
        }
        
        static var count: CGFloat = 5.0
    }
    
    struct Constants {
        static let rowHeight: CGFloat = 37.0
        static let bottomViewHeight: CGFloat = 50.0
        static let sizeCoef: CGFloat = 441.0 / 750.0
        static let animationDuration = 0.3
        static let bottomMargin: CGFloat = 30.0
    }
    
    // MARK: - Properties
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Override methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        registerTableViewCell()
        
        tableViewHeightConstraint.constant = Items.count * Constants.rowHeight
        
        let desiredHeight = ChooseView.desiredHeight()
        let desiredWidth = Constants.sizeCoef * UIScreen.main.bounds.width
        
        let newFrame = CGRect(origin: CGPoint.zero, size: CGSize(width: desiredWidth, height: desiredHeight))
        frame = newFrame
    }
    
    // MARK: - Public methods
    
    func present(on view: UIView) {
        center = view.center
        var newFrame = frame
        newFrame.origin.y = UIScreen.main.bounds.height
        frame = newFrame
        
        view.addSubview(self)
        UIView.animate(withDuration: Constants.animationDuration) {
            var newFrame = self.frame
            newFrame.origin.y = newFrame.origin.y - self.frame.height - Constants.bottomMargin
            self.frame = newFrame
        }
    }
    
    // MARK: - Private methods
    
    fileprivate func registerTableViewCell() {
        tableView.register(UINib(nibName: ChooseTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: ChooseTableViewCell.identifier)
    }
    
    // MARK: - Class methods
    
    class func desiredHeight() -> CGFloat {
        return Items.count * Constants.rowHeight + Constants.bottomViewHeight
    }
    
    // MARK: - Actions
    
    @IBAction func onCancelButtonClicked(sender: UIButton) {
        removeFromSuperview()
    }
}

// MARK: - UITableViewDataSource
extension ChooseView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(Items.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ChooseTableViewCell = tableView.dequeueCell(withIdentifier: ChooseTableViewCell.identifier, for: indexPath)
        
        if let item = Items(rawValue: indexPath.row) {
            cell.iconImageView.image = item.data.1
            cell.titleLabel.text = item.data.0
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ChooseView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.rowHeight
    }
}
