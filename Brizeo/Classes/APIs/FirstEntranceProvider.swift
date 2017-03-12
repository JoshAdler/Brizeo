//
//  FirstEntranceProvider.swift
//  Brizeo
//
//  Created by Roman Bayik on 3/12/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

extension DefaultsKeys {
    static let isFirstEntrancePassed = DefaultsKey<Bool>("isFirstEntrancePassed")
    static let currentStep = DefaultsKey<Int>("currentStep")
    static let goingToCreateMoment = DefaultsKey<Bool>("goingToCreateMoment")
}

enum FirstEntranceLogicStep: Int {
    case profile = 0
    case moments
}

class FirstEntranceProvider {

    // MARK: - Types

    
    // MARK: - Properties
    
    static let shared = FirstEntranceProvider()
    
    var isFirstEntrancePassed: Bool {
        get {
            return Defaults[.isFirstEntrancePassed]
        }
        set {
            Defaults[.isFirstEntrancePassed] = newValue
        }
    }
    
    var currentStep: FirstEntranceLogicStep {
        get {
            return FirstEntranceLogicStep(rawValue: Defaults[.currentStep]) ?? FirstEntranceLogicStep.profile
        }
        set {
            Defaults[.currentStep] = newValue.rawValue
        }
    }
    
    var goingToCreateMoment: Bool {
        get {
            return Defaults[.goingToCreateMoment]
        }
        set {
            Defaults[.goingToCreateMoment] = newValue
        }
    }
    
    // MARK: - Init 
    
    private init() {}
    
    // MARK: - Class methods
    

    
}
