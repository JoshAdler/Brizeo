//
//  LocationManager.swift
//  Brizeo
//
//  Created by Arturo on 5/4/16.
//  Copyright © 2016 Kogi Mobile. All rights reserved.
//

import Foundation
import CoreLocation
import Crashlytics
import Alamofire
import AlamofireImage
import MapKit
import CLLocationManager_blocks

class LocationManager: NSObject {
    
    // MARK: - Types
    
    struct Constants {
        static let googleMapsURL = "https://maps.googleapis.com/maps/api/place/autocomplete/json"
    }
    
    // MARK: - Properties
    
    static let shared = LocationManager()
    
    fileprivate var locationManager: CLLocationManager!
    fileprivate var completionBlock : ((String?, CLLocation?) -> Void)?
    fileprivate var request: Request?
    
    // store location data
    var currentLocationString: String?
    var currentLocationCoordinates: CLLocation?
    
    // MARK: - Class methods
    
    class func setup() {
        CLLocationManager()
        LocationManager.shared.locationManager = CLLocationManager.update(withAccuracy: kCLLocationAccuracyBest, locationAge: 60.0, authorizationDesciption: .whenInUse)

        LocationManager.shared.locationManager.delegate = shared
        LocationManager.shared.locationManager.requestWhenInUseAuthorization()
        LocationManager.shared.locationManager.requestLocation()
    }
    
    class func requestLocation(with text: String?, completionHandler: ((MKLocalSearchResponse?) -> Void)?) {
        guard let searchText = text else {
            return
        }
        
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchText
        
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            completionHandler?(response)
        }
    }

    // MARK: - Private methods
    
    fileprivate func locationStringForPlaceMark(_ placemark: CLPlacemark) -> String {
        if placemark.locality != nil {
            return "\(placemark.locality ?? ""), \(placemark.administrativeArea ?? ""), \(placemark.country ?? "")"
        }
        return ""
    }

    // MARK: Public methods
    
    func checkAccessStatus() {
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                let alert = UIAlertController(title: LocalizableString.Warning.localizedString, message: LocalizableString.LocationDenied.localizedString, preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: LocalizableString.Ok.localizedString, style: .default, handler: { (action) in
                    Helper.openURL(url: URL(string:UIApplicationOpenSettingsURLString)!)
                }))
                
                alert.addAction(UIAlertAction(title: LocalizableString.Later.localizedString, style: .default, handler: nil))
                
                Helper.initialNavigationController().present(alert, animated: true, completion: nil)
            case .authorizedAlways, .authorizedWhenInUse:
                break
            }
        } else {
            let alert = UIAlertController(title: LocalizableString.Warning.localizedString, message: LocalizableString.LocationDisabled.localizedString, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: LocalizableString.Ok.localizedString, style: .default, handler: nil))
            
            Helper.initialNavigationController().present(alert, animated: true, completion: nil)
        }
    }
    
    func updateLocation() {
        locationManager.requestLocation()
    }
    
    func requestCurrentLocation(_ completion: ((String?, CLLocation?) -> Void)?) -> (String?, CLLocation?) {
        completionBlock = completion
        locationManager.requestLocation()
        
        return (currentLocationString, currentLocationCoordinates)
    }
    
    func getLocationStringForLocation(_ location: CLLocation, completion:@escaping ((String) -> Void)) {
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {
            (placemarks, error) -> Void in
            guard error == nil else {
                print(error!)
                return
            }
            
            guard let placemark = placemarks?.first else {
                print("No placemarks")
                return
            }
            
            completion(self.locationStringForPlaceMark(placemark))
        })
    }
    
    func getLocationCoordinateForText(_ text: String, completion:@escaping ((CLLocation?) -> Void)) {
        
        CLGeocoder().geocodeAddressString(text) {
            (placemarks, error) in
            
            var searchLocation: CLLocation? = nil
            if (error == nil && placemarks != nil && !(placemarks!.isEmpty)) {
                searchLocation = placemarks!.first!.location
            }
            
            completion(searchLocation)
        }
    }
    //TODO: check the latest realization for this part
    func getLocationsForText(_ text: String, completion:@escaping (([String]) -> Void))  {
        request?.cancel()
        
        request = Alamofire.request(Constants.googleMapsURL, method: .get, parameters: ["key": GooglePlacesKey.GooglePlacesKey, "input": text, "types": "(cities)"], encoding: JSONEncoding.default, headers: nil).validate().responseJSON{ (response) in
            
           switch response.result {
           case .success(let value):
                var suggestions = [String]()
                if let value = value as? [String: AnyObject], let predictions = value["predictions"] as? [[String: AnyObject]] {
                    
                    for prediction in predictions {
                        if let suggestion = prediction["description"] as? String {
                            suggestions.append(suggestion)
                        }
                    }
                }
                completion(suggestions)
                break
            case .failure(let error):
                CLSLogv("Error getting locations: %@", getVaList([error as CVarArg]))
                break
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            updateLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            print("No location")
            return
        }
        
        print("LocationManager: location was updated")
        
        currentLocationCoordinates = location
        
        getLocationStringForLocation(location, completion: { (locationString) in
            self.currentLocationString = locationString
            self.completionBlock?(locationString, location)
        })
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        CLSLogv("Error getting User location: %@", getVaList([error as CVarArg]))
    }
}
