//
//  Gender.swift
//  Brizeo
//
//  Created by Roman Bayik on 3/3/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import Foundation

enum Gender: String {
    case Man = "male"
    case Woman = "female"
    case Couple = "couple"
    
    static func gender(for index: Int) -> Gender {
        switch index {
        case 0:
            return .Man
        case 1:
            return .Woman
        default:
            return .Couple
        }
    }
    
    var titleSingle: String {
        switch self {
        case .Man:
            return "Man"
        case .Woman:
            return "Woman"
        case .Couple:
            return "Couple"
        }
    }
    
    var titlePlural: String {
        switch self {
        case .Man:
            return "Men"
        case .Woman:
            return "Women"
        case .Couple:
            return "Couple"
        }
    }
    
    static var defaultGender: Gender {
        return .Couple
    }
}
