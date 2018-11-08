//
//  Helpers.swift
//  ForaBank
//
//  Created by Ilya Masalov (xmasalov@gmail.com) on 15/09/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import Foundation
import UIKit
import DeviceKit

extension UIDevice {
    static var hasNotchedDisplay: Bool {
        if let window = UIApplication.shared.keyWindow {
            return (window.compatibleSafeAreaInsets.top > 20.0 || window.compatibleSafeAreaInsets.left > 0.0 || window.compatibleSafeAreaInsets.right > 0.0)
        }
        return false
    }
}

extension UIView {
    var compatibleSafeAreaInsets: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return safeAreaInsets
        } else {
            return .zero
        }
    }
    
    var compatibleSafeAreaLayoutGuide: UILayoutGuide {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide
        } else {
            return layoutMarginsGuide
        }
    }
}

extension UITextField {
    open override var canBecomeFirstResponder: Bool {
        return true
    }
    
    open override func becomeFirstResponder() -> Bool {
        layer.customBorderColor = .white
        layer.cornerRadius = 5.0
        layer.masksToBounds = true
        layer.borderWidth = 1
        super.becomeFirstResponder()
        
        return true
    }
    
    open override func resignFirstResponder() -> Bool {
        layer.customBorderColor = .clear
        super.resignFirstResponder()
        
        return true
    }
}

extension CALayer {
    var customBorderColor: UIColor {
        set {
            self.borderColor = newValue.cgColor
        }
        get {
            return UIColor(cgColor: self.borderColor!)
        }
    }
}

extension UISegmentedControl {
    func setSegmentStyle() {
        
        let segmentGrayColor = UIColor(red: 0.889415, green: 0.889436, blue:0.889424, alpha: 1.0 )
        
        setBackgroundImage(imageWithColor(color: backgroundColor!), for: .normal, barMetrics: .default)
        setBackgroundImage(imageWithColor(color: tintColor!), for: .selected, barMetrics: .default)
        setDividerImage(imageWithColor(color: segmentGrayColor), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        let segAttributes: NSDictionary = [
            NSAttributedString.Key.foregroundColor: UIColor(red: 86/255, green: 86/255, blue: 95/255, alpha: 1),
            NSAttributedString.Key.font: UIFont(name: "Roboto-Regular", size: 14)!
        ]
        setTitleTextAttributes(segAttributes as? [NSAttributedString.Key: Any], for: [])
        let segAttributesExtra: NSDictionary = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: "Roboto-Regular", size: 14)!
            
        ]
        setTitleTextAttributes(segAttributesExtra as? [NSAttributedString.Key: Any], for: .selected)
        selectedSegmentIndex = -1
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 5.0
        self.layer.borderColor = segmentGrayColor.cgColor
        self.layer.masksToBounds = true
    }
    
    // create a 1x1 image with this color
    private func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width:  1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor);
        context!.fill(rect);
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image!
    }
}

extension UIColor {
    convenience init(hexFromString:String, alpha:CGFloat = 1.0) {
        var cString:String = hexFromString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        var rgbValue:UInt32 = 10066329 //color #999999 if string has wrong format
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) == 6) {
            Scanner(string: cString).scanHexInt32(&rgbValue)
        }
        
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}

enum Constants {
    
    static let iphone5Devices: [Device] = [.iPhone5, .iPhone5c, .iPhone5s, .iPhoneSE,
                                           .simulator(.iPhone5), .simulator(.iPhone5c), .simulator(.iPhone5s), .simulator(.iPhoneSE)]
    
    static let xDevices: [Device] = [
        .iPhoneX,
        .iPhoneX,
        .iPhoneXr,
        .iPhoneXs,
        .iPhoneXsMax,
        
        .simulator(.iPhoneX),
        .simulator(.iPhoneX),
        .simulator(.iPhoneXr),
        .simulator(.iPhoneXs),
        .simulator(.iPhoneXsMax)
    ]
}
