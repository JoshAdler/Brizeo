//
//  APIError.swift
//  Brizeo
//
//  Created by Roman Bayik on 3/6/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import Foundation
import Moya

enum APIError: Swift.Error {
    
    case notFound
    case firebaseError
    case unknown(message: String)
    case moyaError(message: String)
    
    init(code: Int, message: String?) {
        switch code {
        case 404:
            self = .notFound
        case 500:
            self = .firebaseError
        default:
            self = .unknown(message: message ?? "Unknown error occured during the process.")
        }
    }
    
    init(error: NSError) {
        self = .unknown(message: error.localizedDescription)
    }
    
    init(error: Swift.Error) {
        self = .unknown(message: error.localizedDescription)
    }
    
    init(error: MoyaError) {
        self = .moyaError(message: error.localizedDescription)
    }
}

extension APIError: Equatable {
    
    static func ==(lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.notFound, .notFound): return true
        case (.firebaseError, .firebaseError): return true
        default:
            return false
        }
    }
}

// MARK: - Error Descriptions

extension APIError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .firebaseError:
            return "Server error took place during operation."
        case .notFound:
            return "The object is not founded."
        case .moyaError(let message):
            return message
        case .unknown(let message):
            return message
        }
    }
}
