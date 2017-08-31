//
//  OptionsWorkViewController.swift
//  Brizeo
//
//  Created by Roman Bayik on 8/30/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import CoreLocation
import ChameleonFramework

public let ErrorDomain: String! = "GooglePlacesAutocompleteErrorDomain"

fileprivate struct LocationBias {
    public let latitude: Double
    public let longitude: Double
    public let radius: Int
    
    public init(latitude: Double = 0, longitude: Double = 0, radius: Int = 20000000) {
        self.latitude = latitude
        self.longitude = longitude
        self.radius = radius
    }
    
    public var location: String {
        return "\(latitude),\(longitude)"
    }
}

fileprivate class Place: NSObject {
    open let id: String
    open let desc: String
    open var address: String?
    open var apiKey: String?
    open var location: CLLocationCoordinate2D?
    
    override open var description: String {
        get { return desc }
    }
    
    public init(id: String, description: String) {
        self.id = id
        self.desc = description
    }
    
    public convenience init(prediction: [String: AnyObject], apiKey: String?) {
        self.init(
            id: prediction["place_id"] as! String,
            description: prediction["description"] as! String
        )
        
        self.apiKey = apiKey
    }
    
    public convenience init(result: [String: AnyObject], apiKey: String?) {
        self.init(
            id: result["id"] as! String,
            description: result["name"] as! String
        )
        
        self.apiKey = apiKey
    }
    
    class func initialize(result: [String: AnyObject], apiKey: String?) -> Place {
        
        let place = Place(
            id: result["place_id"] as! String,
            description: result["name"] as! String
        )
        
        place.apiKey = apiKey
        
        // location
        if let location = result["geometry"]?["location"] as? [String: Double], let latitude = location["lat"], let longitude = location["lng"] {
            place.location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        
        // if address 
        if let address = result["formatted_address"] as? String {
            place.address = address
        }
        
        return place
    }
    
    class func initializeSearch(result: [String: AnyObject], apiKey: String?) -> Place {
        
        let place = Place(
            id: result["id"] as! String,
            description: result["name"] as! String
        )
        
        place.apiKey = apiKey
        
        // location
        if let location = result["geometry"]?["location"] as? [String: Double], let latitude = location["lat"], let longitude = location["lng"] {
            place.location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        
        return place
    }
    
    /**
     Call Google Place Details API to get detailed information for this place
     
     Requires that Place#apiKey be set
     
     - parameter result: Callback on successful completion with detailed place information
     */
    open func getDetails(_ result: @escaping (PlaceDetails) -> ()) {
        GooglePlaceDetailsRequest(place: self).request(result)
    }
}

fileprivate class PlaceDetails: CustomStringConvertible {
    
    open let name: String
    open let latitude: Double
    open let longitude: Double
    open let raw: [String: AnyObject]
    
    public init(json: [String: AnyObject]) {
        let result = json["result"] as! [String: AnyObject]
        let geometry = result["geometry"] as! [String: AnyObject]
        let location = geometry["location"] as! [String: AnyObject]
        
        self.name = result["name"] as! String
        self.latitude = location["lat"] as! Double
        self.longitude = location["lng"] as! Double
        self.raw = json
    }
    
    open var description: String {
        return "PlaceDetails: \(name) (\(latitude), \(longitude))"
    }
}

@objc fileprivate protocol GooglePlacesAutocompleteDelegate {
    @objc optional func placesFound(_ places: [Place])
    @objc optional func placeSelected(_ place: Place?)
    @objc optional func placeViewClosed()
}

// MARK: - GooglePlaceDetailsRequest
fileprivate class GooglePlaceDetailsRequest {
    let place: Place
    
    init(place: Place) {
        self.place = place
    }
    
    func request(_ result: @escaping (PlaceDetails) -> ()) {
        GooglePlacesRequestHelpers.doRequest(
            "https://maps.googleapis.com/maps/api/place/details/json",
            params: [
                "placeid": place.id,
                "key": place.apiKey ?? ""
            ]
        ) { json, error in
            if let json = json as? [String: AnyObject] {
                result(PlaceDetails(json: json))
            }
            if let error = error {
                // TODO: We should probably pass back details of the error
                print("Error fetching google place details: \(error)")
            }
        }
    }
}

// MARK: - GooglePlacesRequestHelpers
fileprivate class GooglePlacesRequestHelpers {
    /**
     Build a query string from a dictionary
     
     - parameter parameters: Dictionary of query string parameters
     - returns: The properly escaped query string
     */
    fileprivate class func query(_ parameters: [String: AnyObject]) -> String {
        var components: [(String, String)] = []
        for key in Array(parameters.keys).sorted(by: <) {
            let value = parameters[key] as! String
            components += [(escape(key), escape("\(value)"))]
        }
        
        return (components.map{"\($0)=\($1)"} as [String]).joined(separator: "&")
    }
    
    fileprivate class func escape(_ string: String) -> String {
        let legalURLCharactersToBeEscaped: CFString = ":/?&=;+!@#$()',*" as CFString
        return CFURLCreateStringByAddingPercentEscapes(nil, string as CFString!, nil, legalURLCharactersToBeEscaped, CFStringBuiltInEncodings.UTF8.rawValue) as String
    }
    
    fileprivate class func doRequest(_ url: String, params: [String: String], completion: @escaping (NSDictionary?,Error?) -> ()) {
        let request = URLRequest(url: URL(string: "\(url)?\(query(params as [String : AnyObject]))")!)
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { (data:Data?, response:URLResponse?, error:Error?) in
            self.handleResponse(data, response: response as! HTTPURLResponse, error: error, completion: completion)
        }
        
        task.resume()
    }
    
    fileprivate class func handleResponse(_ data: Data!, response: HTTPURLResponse!, error: Error!, completion: @escaping (NSDictionary?, Error?) -> ()) {
        
        // Always return on the main thread...
        let done: ((NSDictionary?, Error?) -> Void) = {(json, error) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                completion(json,error)
            })
        }
        
        if let error = error {
            print("GooglePlaces Error: \(error.localizedDescription)")
            done(nil,error)
            return
        }
        
        if response == nil {
            print("GooglePlaces Error: No response from API")
            let error = NSError(domain: ErrorDomain, code: 1001, userInfo: [NSLocalizedDescriptionKey:"No response from API"])
            done(nil,error)
            return
        }
        
        if response.statusCode != 200 {
            print("GooglePlaces Error: Invalid status code \(response.statusCode) from API")
            let error = NSError(domain: ErrorDomain, code: response.statusCode, userInfo: [NSLocalizedDescriptionKey:"Invalid status code"])
            done(nil,error)
            return
        }
        
        let json: NSDictionary?
        do {
            json = try JSONSerialization.jsonObject(
                with: data,
                options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
        } catch {
            print("Serialisation error")
            let serialisationError = NSError(domain: ErrorDomain, code: 1002, userInfo: [NSLocalizedDescriptionKey:"Serialization error"])
            done(nil,serialisationError)
            return
        }
        
        if let status = json?["status"] as? String {
            if status != "OK" {
                print("GooglePlaces API Error: \(status)")
                let error = NSError(domain: ErrorDomain, code: 1002, userInfo: [NSLocalizedDescriptionKey:status])
                done(nil,error)
                return
            }
        }
        
        done(json,nil)
        
    }
}

// MARK: - OptionsEducationViewController
class OptionsEducationViewController: OptionsViewController {

    // MARK: - Properties
    
    fileprivate var places: [Place]?
    fileprivate var bias: LocationBias?
    fileprivate var latestRequestId: String!
    
    // MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        
        // register header
        tableView.register(UINib(nibName: SearchHeaderView.nibName, bundle: nil), forHeaderFooterViewReuseIdentifier: SearchHeaderView.nibName)
        
        // set type
        self.type = .education
        
        // set location bias
        if let location = LocationManager.shared.currentLocationCoordinates?.coordinate {
            self.bias = LocationBias(latitude: location.latitude, longitude: location.longitude, radius: 20000)
        }
        
        super.viewDidLoad()
        
        
//        searchBar.placeholder = isAutocomplete ? "Select a Location" : "Select a University"
        
        runSearch(searchText: "")
    }
    
    override func onBackButtonClicked(sender: UIBarButtonItem?) {
        
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
    
    fileprivate func runSearch(searchText: String) {
        
        if (searchText == "") {
            
            self.places = []
            tableView.isHidden = true
            
            if bias != nil {
                latestRequestId = UUID().uuidString
                getNearbyUniversities(with: latestRequestId)
            }
        } else {
            
            latestRequestId = UUID().uuidString
            getPlaces(searchText, id: latestRequestId)
        }
    }
    
    fileprivate func getNearbyUniversities(with id: String) {
        
        var params = [
            "key": Configurations.GooglePlaces.key,
            "rankby": "prominence",
            "type": "university"
        ]
        
        if let bias = bias {
            params["location"] = bias.location
            params["radius"] = bias.radius.description
        }
        
        GooglePlacesRequestHelpers.doRequest(
            "https://maps.googleapis.com/maps/api/place/nearbysearch/json",
            params: params
        ) { [weak self] json, error in
            
            guard self != nil else {
                return
            }
            
            guard self!.latestRequestId == id else {
                return
            }
            
            if let json = json {
                if let results = json["results"] as? [[String: AnyObject]] {
                    
                    self!.places = results.map { (result: [String: AnyObject]) -> Place in
                        let place = Place.initialize(result: result, apiKey: Configurations.GooglePlaces.key)
                        return place
                    }
                    
                    self!.tableView.reloadData()
                    self!.tableView.isHidden = false
                }
            }
        }
    }
    
    fileprivate func getPlaces(_ searchString: String, id: String) {
        
        let url = "https://maps.googleapis.com/maps/api/place/textsearch/json"
        
        let params = [
            "query": searchString,
            "type": "university",
            "key": Configurations.GooglePlaces.key,
            ]
        
        if (searchString == ""){
            return
        }
        
        GooglePlacesRequestHelpers.doRequest(
            url,
            params: params
        ) { [weak self] json, error in
            
            
            guard self != nil else {
                return
            }
            
            guard self!.latestRequestId == id else {
                return
            }
            
            if let json = json {
                
                if let results = json["results"] as? Array<[String: AnyObject]> {
                    self!.places = results.map { (result: [String: AnyObject]) -> Place in
                        
                        let place = Place.initialize(result: result, apiKey: Configurations.GooglePlaces.key)
                        return place
                    }
                    
                    self!.places?.sort(by: { return $0.desc < $1.desc })
                    self!.tableView.reloadData()
                    self!.tableView.isHidden = false
                }
            }
        }
    }
}

// MARK: - UITextFieldDelegate
extension OptionsEducationViewController {
    
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
//        if let text = textField.text {
//            if text.numberOfCharactersWithoutSpaces() > 0 {
//                if type == .work {
//                    user.workInfo = textField.text
//                } else { // education
//                    user.studyInfo = textField.text
//                }
//                
//                tableView.reloadData()
////                onBackButtonClicked(sender: nil)
//            }
//        }
        
        return true
    }
}

// MARK: - UITableViewDataSource / UITableViewDelegate
extension OptionsEducationViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return super.tableView(tableView, numberOfRowsInSection: section)
        } else {
            return places?.count ?? 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            return super.tableView(tableView, cellForRowAt: indexPath)
        } else { // input cell
            
            let cell: SettingsCheckmarkCell = tableView.dequeueCell(withIdentifier: SettingsCheckmarkCell.identifier, for: indexPath)
            
            let place = places![indexPath.row]
            var text = place.description
            
            if let address = place.address, address.numberOfCharactersWithoutSpaces() > 0 {
                text += " at \(address)"
            }
            
            cell.titleLabel.text = text
            
            var isChecked = false
            
            if let placeId = user.studyPlaceId {
                isChecked = placeId == place.id
            } else {
                isChecked = place.description == user.studyInfo
            }
            
            cell.isChecked = isChecked
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        view.endEditing(true)
        
        user.studyPlaceId = nil
        
        if indexPath.section == 0 {
            super.tableView(tableView, didSelectRowAt: indexPath)
        } else { // input cell
            
            let place = places![indexPath.row]
            user.studyInfo = place.description
            user.studyPlaceId = place.id
            
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        if section == 0 {
            return super.tableView(tableView, heightForHeaderInSection: section)
        }
        
        return 100
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {
            return super.tableView(tableView, viewForHeaderInSection: section)
        } else {
            
            let headerView: SearchHeaderView = tableView.dequeueReusableHeaderFooterView(withIdentifier: SearchHeaderView.nibName)
            let sectionTitle = "General School (Click Return to Add)"
            
            headerView.delegate = self
            headerView.searchField.placeholder = LocalizableString.SelectUniversityToSearch.rawValue
            headerView.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: tableView.frame.width, height: Constants.headerHeight))
            headerView.contentView.backgroundColor = HexColor("224EA3")
            headerView.titleLabel.text = sectionTitle
            headerView.titleLabel.textColor = .white
            
            return headerView
        }
    }
}

// MARK: - SearchHeaderViewDelegate
extension OptionsEducationViewController: SearchHeaderViewDelegate {
    
    func searchHeader(_ view: SettingsHeaderView, didChanged text: String?) {
        
        runSearch(searchText: text ?? "")
    }
}
