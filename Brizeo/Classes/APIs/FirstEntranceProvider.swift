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
    static let isAlreadyViewedEvents = DefaultsKey<Bool>("isAlreadyViewedEvents")
    static let isAlreadyViewedSearch = DefaultsKey<Bool>("isAlreadyViewedSearch")
    static let isAlreadyViewedSettings = DefaultsKey<Bool>("isAlreadyViewedSettings")
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
    
    var isAlreadyViewedEvents: Bool {
        get {
            return Defaults[.isAlreadyViewedEvents]
        }
        set {
            Defaults[.isAlreadyViewedEvents] = newValue
        }
    }
    
    var isAlreadyViewedSearch: Bool {
        get {
            return Defaults[.isAlreadyViewedSearch]
        }
        set {
            Defaults[.isAlreadyViewedSearch] = newValue
        }
    }
    
    var isAlreadyViewedSettings: Bool {
        get {
            return Defaults[.isAlreadyViewedSettings]
        }
        set {
            Defaults[.isAlreadyViewedSettings] = newValue
        }
    }
}
