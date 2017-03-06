//
//  Extensions.swift
//  Brizeo
//
//  Created by Roman Bayik on 2/8/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import MapKit
import Branch

// MARK: - NSLayoutConstraint
extension NSLayoutConstraint {
    
    func constraintWithMultiplier(multiplier: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self.firstItem, attribute: self.firstAttribute, relatedBy: self.relation, toItem: self.secondItem, attribute: self.secondAttribute, multiplier: multiplier, constant: self.constant)
    }
}

// MARK - MKPlacemark
extension MKPlacemark {
    
    func asString() -> String {
        // put a space between "4" and "Melrose Place"
        let firstSpace = (subThoroughfare != nil && thoroughfare != nil) ? " " : ""
        // put a comma between street and city/state
        let comma = (subThoroughfare != nil || thoroughfare != nil) && (subAdministrativeArea != nil || administrativeArea != nil) ? ", " : ""
        // put a space between "Washington" and "DC"
        let secondSpace = (subAdministrativeArea != nil && administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            subThoroughfare ?? "",
            firstSpace,
            // street name
            thoroughfare ?? "",
            comma,
            // city
            locality ?? "",
            secondSpace,
            // state
            administrativeArea ?? ""
        )
        return addressLine
    }
}

// MARK: - UITableViewCell

extension UITableViewCell {

    class var identifier: String {
        return String(describing: self)
    }
}

// MARK: - UICollectionViewCell
extension UICollectionViewCell {
    
    class var identifier: String {
        return String(describing: self)
    }
}

// MARK: - Date
extension Date {
 
    var age: Int {
        return Calendar.current.dateComponents([.year], from: self, to: Date()).year!
    }
    
    var toLongString: String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return dateFormatter.string(from: self)
    }
}

// MARK: - String
extension String {
    
    var urlEscaped: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    var utf8Encoded: Data {
        return self.data(using: .utf8)!
    }
    
    func numberOfCharactersWithoutSpaces() -> Int {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).characters.count
    }
}

// MARK: - NSString
extension NSString {
    func heightWithConstrainedWidth(_ witdth: CGFloat) -> CGFloat {
        let constrainedRect = CGSize(width: witdth, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constrainedRect, options: .usesLineFragmentOrigin, attributes: nil, context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func widthWithConstrainedHeight(_ height: CGFloat) -> CGFloat {
        let constrainedRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constrainedRect, options: .usesLineFragmentOrigin, attributes: nil, context: nil)
        
        return ceil(boundingBox.height)
    }
}

// MARK: - Branch
extension Branch {
    static var currentInstance: Branch {
        #if PRODUCTION
            return Branch.getInstance()
        #else
            return Branch.getTestInstance()
        #endif
    }
}


// MARK: - UITableView
extension UITableView {
    func dequeueCell<T: UITableViewCell>(withIdentifier identifier: String, for indexPath: IndexPath) -> T {
        return dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! T
    }
    
    func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>(withIdentifier identifier: String) -> T {
        return dequeueReusableHeaderFooterView(withIdentifier: identifier) as! T
    }
}

// MARK: - UIView
@IBDesignable
extension UIView {
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get { return layer.cornerRadius }
        set { layer.cornerRadius = newValue }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get { return layer.borderWidth }
        set { layer.borderWidth = newValue }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            if let borderColor = layer.borderColor {
                return UIColor(cgColor: borderColor)
            }
            return nil
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    class var nibName: String {
        return String(describing: self)
    }
    
    class func loadFromNib<T>() -> T {
        let nib = UINib(nibName: nibName, bundle: nil)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! T
        
        return view
    }
}
