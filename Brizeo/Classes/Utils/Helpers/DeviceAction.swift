//
//  DeviceAction.swift
//  Brizeo
//
//  Created by Giovanny Orozco on 4/21/16.
//  Copyright © 2016 Kogi Mobile. All rights reserved.
//

import Foundation
import CoreTelephony

enum PhoneNumberAction {
    
    case call
    case message
    case createContact
    case copytext
}

struct DeviceAction {

    static func createActionSeetActions(_ phoneNumber: String, completion: @escaping (PhoneNumberAction) -> Void) -> UIAlertController {
    
        let phoneOptionsAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: LocalizableString.Cancel.localizedString, style: .cancel, handler: nil)
        
        if(UIApplication.shared.canOpenURL(URL(string:"tel://")!)) {
            
            let netInfo = CTTelephonyNetworkInfo()
            let carrier = netInfo.subscriberCellularProvider
            let mnc = carrier?.mobileNetworkCode
            
            if let mnc = mnc , !mnc.isEmpty {
                
                let callAction = UIAlertAction(title: LocalizableString.Call.localizedString, style: .default) { (action) in
                    
                    if let phoneURL = URL(string: "tel://\(phoneNumber)") {
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
                        } else {
                            UIApplication.shared.openURL(phoneURL)
                        }
                        completion(.call)
                    }
                }
                
                phoneOptionsAlertController.addAction(callAction)
            }
        }
        
        if(UIApplication.shared.canOpenURL(URL(string:"sms://")!)) {
            
            let smsMessageAction = UIAlertAction(title: LocalizableString.SendMessage.localizedString, style: .default) { (action) in
                
                if let smsURL = URL(string: "sms:\(phoneNumber)") {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(smsURL, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(smsURL)
                    }
                    completion(.message)
                }
            }
            phoneOptionsAlertController.addAction(smsMessageAction)
        }
        
        let addContactAction = UIAlertAction(title: LocalizableString.CreateContact.localizedString, style: .default) { (action) in
            completion(.createContact)
        }
        
        let copyNumberAction = UIAlertAction(title: LocalizableString.Copy.localizedString, style: .default) { (action) in
            UIPasteboard.general.string = phoneNumber
        }
        
        phoneOptionsAlertController.addAction(cancelAction)
        phoneOptionsAlertController.addAction(addContactAction)
        phoneOptionsAlertController.addAction(copyNumberAction)

        return phoneOptionsAlertController
    }
}
