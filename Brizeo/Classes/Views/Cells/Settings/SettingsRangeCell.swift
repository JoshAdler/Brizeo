//
//  RangeDistanceTableViewCell.swift
//  Brizeo
//
//  Created by Arturo on 5/2/16.
//  Copyright © 2016 Kogi Mobile. All rights reserved.
//

import UIKit
import MSRangeSlider

protocol SettingsRangeCellDelegate: class {
    
    func rangeCellDidSetAgeValue(_ rangeCell: SettingsRangeCell, ageMinValue: Int, ageMaxValue: Int)
    func rangeCellDidSetDistanceValue(_ rangeCell: SettingsRangeCell, distanceValue: Int)
    
}

class SettingsRangeCell: UITableViewCell {

    // MARK: - Properties
    
    @IBOutlet weak var ageRangeLabel: UILabel?
    @IBOutlet weak var ageRangeSlider: MSRangeSlider?
    @IBOutlet weak var ageRangeValueLabel: UILabel?
    @IBOutlet weak var distanceLabel: UILabel?
    @IBOutlet weak var distanceValueLabel: UILabel?
    @IBOutlet weak var distanceSlider: UISlider? {
        didSet {
            distanceSlider?.setThumbImage(#imageLiteral(resourceName: "ic_range_thumb"), for: .normal)
        }
    }
    
    weak var delegate: SettingsRangeCellDelegate?
    
    // MARK: - Override methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        ageRangeLabel?.text = LocalizableString.AgeRange.localizedString
        distanceLabel?.text = LocalizableString.MaximumDistance.localizedString
        
        ageRangeSlider?.minimumValue = Configurations.Settings.minAgeValue
        ageRangeSlider?.maximumValue = Configurations.Settings.maxAgeValue
        distanceSlider?.minimumValue = Configurations.Settings.minDistanceValue
        distanceSlider?.maximumValue = Configurations.Settings.maxDistanceValue
    }
 
    // MARK: - Public methods
    
    func setupWithRange(_ minAgeRange: Int, maxAgeRange: Int, distanceRange: Int) {
    
        let minAgeRangeValue = CGFloat(minAgeRange)
        let maxAgeRangeValue = CGFloat(maxAgeRange)
        let distanceRangeValue = Float(distanceRange)
        
        if minAgeRangeValue >= Configurations.Settings.minAgeValue && minAgeRangeValue <= Configurations.Settings.maxAgeValue && minAgeRangeValue < maxAgeRangeValue {

            ageRangeSlider?.fromValue = minAgeRangeValue
        } else {
            ageRangeSlider?.fromValue = Configurations.Settings.minAgeValue
        }
        
        if maxAgeRangeValue >= Configurations.Settings.minAgeValue && maxAgeRangeValue <= Configurations.Settings.maxAgeValue && Configurations.Settings.maxAgeValue > minAgeRangeValue {
            
            ageRangeSlider?.toValue = maxAgeRangeValue
        } else {
            ageRangeSlider?.toValue = Configurations.Settings.maxAgeValue
        }
        
        if distanceRangeValue >= Configurations.Settings.minDistanceValue && distanceRangeValue <= Configurations.Settings.maxDistanceValue {
            
            distanceSlider?.value = distanceRangeValue
        
        } else {
            distanceSlider?.value = Configurations.Settings.minDistanceValue
        }
        
        updateAgeRangeLabel()
        updateDistanceRangeLabel()
    }
    
    func updateAgeRangeLabel() {
        
        if let ageRangeSlider = ageRangeSlider {
            let ageMinValue = Int(ageRangeSlider.fromValue)
            let ageMaxValue = Int(ageRangeSlider.toValue)
            let plus = ageMaxValue >= 85 ? "+" : ""
            
            ageRangeValueLabel?.text = "\(ageMinValue)-\(ageMaxValue)\(plus)"
        }
    }
    
    func updateDistanceRangeLabel() {
        
        if let distanceSlider = distanceSlider {
            let distanceValue = Int(distanceSlider.value)
            
            if distanceValue == 1 {
                distanceValueLabel?.text = LocalizableString.OneMileAwayWithNumber.rawValue
            } else {
                distanceValueLabel?.text = LocalizableString.MilesAway.localizedStringWithArguments([String(format: "%d", distanceValue)])
            }
        }
    }
    
    // MARK: Actions
    
    @IBAction func ageRangeSliderDidChangeValue(_ sender: MSRangeSlider) {
        updateAgeRangeLabel()
        delegate?.rangeCellDidSetAgeValue(self, ageMinValue: Int(sender.fromValue), ageMaxValue: Int(sender.toValue))
    }
    
    @IBAction func distanceSliderDidChangeValue(_ sender: UISlider) {
        updateDistanceRangeLabel()
        delegate?.rangeCellDidSetDistanceValue(self, distanceValue: Int(sender.value))
    }
}
