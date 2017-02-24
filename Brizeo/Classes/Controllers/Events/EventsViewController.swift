//
//  EventsViewController.swift
//  Brizeo
//
//  Created by Roman Bayik on 1/27/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import ChameleonFramework
import SDWebImage

class EventsViewController: UIViewController {

    // MARK: - Types
    
    struct Constants {
        static let cornerRadius: CGFloat = 5.0
        static let borderWidth: CGFloat = 1.0
        static let cellId = "EventTableViewCell"
        static let cellHeightCoef: CGFloat = 637.0 / 926.0
    }
    
    // MARK: - Properties
    
    @IBOutlet weak var locationImageView: UIImageView! {
        didSet {
            locationImageView.image = locationImageView.image!.withRenderingMode(.alwaysTemplate)
        }
    }
    
    @IBOutlet weak var filterImageView: UIImageView! {
        didSet {
            filterImageView.image = filterImageView.image!.withRenderingMode(.alwaysTemplate)
        }
    }
    
    @IBOutlet weak var filterListButton: DropMenuButton! {
        didSet {
            filterListButton.backgroundColor = .clear
            filterListButton.layer.cornerRadius = Constants.cornerRadius
            filterListButton.layer.borderWidth = Constants.borderWidth
            filterListButton.layer.borderColor = HexColor("cccccc")!.cgColor
        }
    }
    
    @IBOutlet weak var locationTextField: UITextField! {
        didSet {
            locationTextField.backgroundColor = .clear
            locationTextField.layer.cornerRadius = Constants.cornerRadius
            locationTextField.layer.borderWidth = Constants.borderWidth
            locationTextField.layer.borderColor = HexColor("cccccc")!.cgColor
        }
    }
    
    var eventList: NSMutableArray!
    
    // MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.initData()
        
        filterListButton.initMenu(["Popularity", "Nearest"], actions: [({ () -> (Void) in
            print("On Popularity button clicked")
        }), ({ () -> (Void) in
            print("On Nearest button clicked")
        })])
    }
    
    func initData() {
        let filePath = Bundle.main.path(forResource: "EventList", ofType: "plist")
        eventList = NSMutableArray(contentsOfFile: filePath!)
    }
}

// MARK: - UITableViewDataSource
extension EventsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellId, for: indexPath) as! EventTableViewCell
        
        let eventDic = eventList.object(at: indexPath.row) as! NSDictionary
        
        cell.eventName.text = eventDic.object(forKey: "eventName") as! String?
        cell.eventImageView.sd_setImage(with: URL(string: eventDic.object(forKey: "eventImage") as! String)!)
        cell.eventOwnerImageView.sd_setImage(with: URL(string: eventDic.object(forKey: "ownerImage") as! String)!)
        cell.eventDescription.text = eventDic.object(forKey: "eventDescription") as? String
        cell.eventStartDate.text = eventDic.object(forKey: "eventDate") as? String
        cell.distanceLabel.text = eventDic.object(forKey: "eventLocation") as? String
        cell.attendingLabel.text = eventDic.object(forKey: "eventAttending") as? String
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension EventsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.cellHeightCoef * tableView.frame.height
    }
}
