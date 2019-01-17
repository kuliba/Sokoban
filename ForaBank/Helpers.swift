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
import FlexiblePageControl

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
        layer.customBorderColor = .red
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

class CustomTextField: UITextField {
    var selectedBorderColor: UIColor = .red
    var defaultBorderColor: UIColor = .clear
    open override var canBecomeFirstResponder: Bool {
        return true
    }
    
    open override func becomeFirstResponder() -> Bool {
        layer.customBorderColor = selectedBorderColor
        layer.cornerRadius = 5.0
        layer.masksToBounds = true
        layer.borderWidth = 1
        super.becomeFirstResponder()
        
        return true
    }
    
    open override func resignFirstResponder() -> Bool {
        layer.customBorderColor = defaultBorderColor
        super.resignFirstResponder()
        
        return true
    }
}

extension UISegmentedControl {
    func setSegmentStyle() {
        
        let segmentGrayColor = UIColor(red: 0.889415, green: 0.889436, blue:0.889424, alpha: 1.0 )
        
        setBackgroundImage(imageWithColor(color: UIColor.clear), for: .normal, barMetrics: .default)
        setBackgroundImage(imageWithColor(color: tintColor!), for: .selected, barMetrics: .default)
        setDividerImage(imageWithColor(color: segmentGrayColor), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        setDividerImage(imageWithColor(color: tintColor!), forLeftSegmentState: .selected, rightSegmentState: .selected, barMetrics: .default)
        setDividerImage(imageWithColor(color: tintColor!), forLeftSegmentState: .normal, rightSegmentState: .selected, barMetrics: .default)
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
        self.layer.backgroundColor = UIColor.clear.cgColor
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 21.0
        self.layer.borderColor = UIColor.clear.cgColor//segmentGrayColor.cgColor
        self.layer.masksToBounds = true
//        let viewForGrayBorder = UIView(frame: bounds)
//        viewForGrayBorder.backgroundColor = tintColor
//        self.insertSubview(viewForGrayBorder, at: 0)
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
    convenience init?(hexFromString:String, alpha:CGFloat = 1.0) {
        var cString:String = hexFromString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        var rgbValue:UInt32 = 10066329 //color #999999 if string has wrong format
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) == 6) {
            Scanner(string: cString).scanHexInt32(&rgbValue)
        } else {
            return nil
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

enum Direction {
    case left
    case right
    case top
    case bottom
    case none
}

protocol CustomTransitionOriginator {
    var fromAnimatedSubviews: [String : UIView] { get }
}

protocol CustomTransitionDestination {
    var toAnimatedSubviews: [String : UIView] { get }
}

struct MultiRange: Sequence {
    let ranges: [Range<Int>]
    
    init(_ ranges: Range<Int>...) {
        self.ranges = ranges
    }
    
    func makeIterator() -> MultiRangeIterator {
        return MultiRangeIterator(self)
    }
}

struct MultiRangeIterator: IteratorProtocol {
    let multiRange: MultiRange
    var index = IndexPath(item: 0, section: 0)
    
    init(_ multiRange: MultiRange) {
        self.multiRange = multiRange
    }
    
    mutating func next() -> Int? {
        if index.section < multiRange.ranges.count {
            let r = multiRange.ranges[index.section]
            if index.item < r.count {
                let nextInt = r.lowerBound + index.item
                index.item += 1
                return nextInt
            }
            else {
                index.section +=  1
                index.item = 0
                return next()
            }
        } else {
            return nil
        }
    }
}

func decodeToInt<T>(fromContainer: KeyedDecodingContainer<T>, key: KeyedDecodingContainer<T>.Key) -> Int? {
    if let stringProperty = try? fromContainer.decodeIfPresent(String.self, forKey: key) {
        if let s = stringProperty {
            return Int(s)
        } else {
            return nil
        }
    } else if let intProperty = try? fromContainer.decodeIfPresent(Int.self, forKey: key) {
        return intProperty
    } else if let doubleProperty = try? fromContainer.decodeIfPresent(Double.self, forKey: key) {
        if let d = doubleProperty {
            return Int(d)
        } else {
            return nil
        }
    } else if let intProperty = try? fromContainer.decodeIfPresent(Int64.self, forKey: key) {
        if let i = intProperty {
            return Int(i)
        } else {
            return nil
        }
    } else {
        print("cant parse value for key \(key)")
        return nil
    }
}

func decodeToInt64<T>(fromContainer: KeyedDecodingContainer<T>, key: KeyedDecodingContainer<T>.Key) -> Int64? {
    if let stringProperty = try? fromContainer.decodeIfPresent(String.self, forKey: key) {
        if let s = stringProperty {
            return Int64(s)
        } else {
            return nil
        }
    } else if let intProperty = try? fromContainer.decodeIfPresent(Int.self, forKey: key) {
        if let i = intProperty {
            return Int64(i)
        } else {
            return nil
        }
    } else if let doubleProperty = try? fromContainer.decodeIfPresent(Double.self, forKey: key) {
        if let d = doubleProperty {
            return Int64(d)
        } else {
            return nil
        }
    } else if let intProperty = try? fromContainer.decodeIfPresent(Int64.self, forKey: key) {
        return intProperty
    } else {
        print("cant parse value for key \(key)")
        return nil
    }
}

func decodeToDouble<T>(fromContainer: KeyedDecodingContainer<T>, key: KeyedDecodingContainer<T>.Key) -> Double? {
    if let stringProperty = try? fromContainer.decodeIfPresent(String.self, forKey: key) {
        if let s = stringProperty {
            return Double(s)
        } else {
            return nil
        }
    } else if let intProperty = try? fromContainer.decodeIfPresent(Int.self, forKey: key) {
        if let i = intProperty {
            return Double(i)
        } else {
            return nil
        }
    } else if let doubleProperty = try? fromContainer.decodeIfPresent(Double.self, forKey: key) {
        return doubleProperty
    } else if let intProperty = try? fromContainer.decodeIfPresent(Int64.self, forKey: key) {
        if let i = intProperty {
            return Double(i)
        } else {
            return nil
        }
    } else {
        print("cant parse value for key \(key)")
        return nil
    }
}
func decodeToString<T>(fromContainer: KeyedDecodingContainer<T>, key: KeyedDecodingContainer<T>.Key) -> String? {
    if let stringProperty = try? fromContainer.decodeIfPresent(String.self, forKey: key) {
        return stringProperty
    } else if let intProperty = try? fromContainer.decodeIfPresent(Int.self, forKey: key) {
        if let i = intProperty {
            return "\(i)"
        } else {
            return nil
        }
    } else if let doubleProperty = try? fromContainer.decodeIfPresent(Double.self, forKey: key) {
        if let d = doubleProperty {
            return "\(d)"
        } else {
            return nil
        }
    } else if let intProperty = try? fromContainer.decodeIfPresent(Int64.self, forKey: key) {
        if let i = intProperty {
            return "\(i)"
        } else {
            return nil
        }
    } else {
        print("cant parse value for key \(key)")
        return nil
    }
}

extension FlexiblePageControl.Config {
    public init(displayCount: Int, dotSize: CGFloat, dotSpace: CGFloat, smallDotSizeRatio: CGFloat, mediumDotSizeRatio: CGFloat) {
        self.displayCount = displayCount
        self.dotSize = dotSize
        self.dotSpace = dotSpace
        self.smallDotSizeRatio = smallDotSizeRatio
        self.mediumDotSizeRatio = mediumDotSizeRatio
    }
}

extension String {
    func replace(string:String, replacement:String) -> String {
        return self.replacingOccurrences(of: string, with: replacement, options: NSString.CompareOptions.literal, range: nil)
    }
    
    func removeWhitespace() -> String {
        return self.replace(string: " ", replacement: "")
    }
}
