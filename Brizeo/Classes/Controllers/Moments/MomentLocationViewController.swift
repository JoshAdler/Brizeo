//
//  MomentLocationViewController.swift
//  Brizeo
//
//  Created by Roman Bayik on 2/10/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MomentLocationViewController: UIViewController {

    // MARK: - Properties
    
    @IBOutlet weak var mapView: MKMapView!
    
    var coordinates: CLLocationCoordinate2D!
    var text: String?
    
    // MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dropDestinationPin()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Private methods
    
    fileprivate func dropDestinationPin() {
        let pin = MKPointAnnotation()
        pin.coordinate = coordinates
        pin.title = text
        mapView.addAnnotation(pin)
        
        let span = MKCoordinateSpanMake(0.5, 0.5)
        let region = MKCoordinateRegion(center: pin.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    // MARK: - Actions
    
    @IBAction func onBackButtonClicked(sender: UIButton) {
        _ = navigationController?.popViewController(animated: true)
    }
}
