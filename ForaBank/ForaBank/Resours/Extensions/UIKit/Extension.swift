//
//  Extension.swift
//  ForaBank
//
//  Created by Дмитрий on 25.06.2021.
//

import Foundation
import UIKit
import Security
import CommonCrypto

extension UIView {
    /** Loads instance from nib with the same name. */
    func loadNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nibName = type(of: self).description().components(separatedBy: ".").last!
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as! UIView
    }
}
extension StringProtocol {
    var data: Data { .init(utf8) }
    var bytes: [UInt8] { .init(utf8) }
}
extension String {
    func base64Encoded() -> String? {
        return data(using: .utf8)?.base64EncodedString()
    }
    func base64Decoded() -> String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
extension StringProtocol {
    var hexaData: Data { .init(hexa) }
    var hexaBytes: [UInt8] { .init(hexa) }
    private var hexa: UnfoldSequence<UInt8, Index> {
        sequence(state: startIndex) { startIndex in
            guard startIndex < self.endIndex else { return nil }
            let endIndex = self.index(startIndex, offsetBy: 2, limitedBy: self.endIndex) ?? self.endIndex
            defer { startIndex = endIndex }
            return UInt8(self[startIndex..<endIndex], radix: 16)
        }
    }
}
extension String {

    func sha256() -> String{
        if let stringData = self.data(using: String.Encoding.utf8) {
            return (digest(input: stringData as NSData).base64EncodedString(options: .endLineWithCarriageReturn))
        }
        return ""
    }

    private func digest(input : NSData) -> NSData {
        let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
        var hash = [UInt8](repeating: 0, count: digestLength)
        CC_SHA256(input.bytes, UInt32(input.length), &hash)
        return NSData(bytes: hash, length: digestLength)
    }

    private  func hexStringFromData(input: NSData) -> String {
        var bytes = [UInt8](repeating: 0, count: input.length)
        input.getBytes(&bytes, length: input.length)

        var hexString = ""
        for byte in bytes {
            hexString += String(format:"%02x", UInt8(byte))
        }

        return hexString
    }
    func encript(string: String) -> String?{
        do {
            guard let key = KeyFromServer.secretKey else {
                return ""
            }
            let aes = try AES(keyString: key)

            let stringToEncrypt: String = "\(string)"

            let encryptedData: Data = try aes.encrypt(stringToEncrypt)
            
            let decryptedData: String = try aes.decrypt(encryptedData)
            return encryptedData.base64EncodedString()
        } catch {
            return nil
        }
    }

}
extension String {
    var digits: String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()
    }
}

protocol OptionalProtocol {
    associatedtype Wrapped
    var optional: Wrapped? { get }
}

extension Optional: OptionalProtocol {
    var optional: Wrapped? {
        return self
    }
}

extension Sequence where Element: OptionalProtocol {
    var removingOptionals: [Element.Wrapped] {
        return self.compactMap { $0.optional }
    }
}

extension UINavigationItem {
    
    func setTitle(title:String, subtitle:String, color: String?) {
        let one = UILabel()
        one.text = title
        one.font = UIFont.systemFont(ofSize: 18)
        one.sizeToFit()
        
        let two = UILabel()
        two.text = subtitle
        two.font = UIFont.systemFont(ofSize: 12)
        two.textAlignment = .center
        two.sizeToFit()
        
        let stackView = UIStackView(arrangedSubviews: [one, two])
        
        stackView.distribution = .equalCentering
        stackView.axis = .vertical
        stackView.alignment = .center
        
        let width = max(one.frame.size.width, two.frame.size.width)
        stackView.frame = CGRect(x: 0, y: 0, width: width, height: 35)
        
        one.textColor = UIColor(hexString: color ?? "FFFFFF")
        two.textColor = UIColor(hexString: color ?? "FFFFFF")
        
        one.sizeToFit()
        two.sizeToFit()
        
        self.titleView = stackView
    }
}


extension UIColor {
    private func makeColor(componentDelta: CGFloat) -> UIColor {
        var red: CGFloat = 0
        var blue: CGFloat = 0
        var green: CGFloat = 0
        var alpha: CGFloat = 0
        
        // Extract r,g,b,a components from the
        // current UIColor
        getRed(
            &red,
            green: &green,
            blue: &blue,
            alpha: &alpha
        )
        
        // Create a new UIColor modifying each component
        // by componentDelta, making the new UIColor either
        // lighter or darker.
        return UIColor(
            red: add(componentDelta, toComponent: red),
            green: add(componentDelta, toComponent: green),
            blue: add(componentDelta, toComponent: blue),
            alpha: alpha
        )
    }
}

extension UIColor {
    // Add value to component ensuring the result is
    // between 0 and 1
    private func add(_ value: CGFloat, toComponent: CGFloat) -> CGFloat {
        return max(0, min(1, toComponent + value))
    }
}

extension UIColor {
    func lighter(componentDelta: CGFloat = 0.1) -> UIColor {
        return makeColor(componentDelta: componentDelta)
    }
    
    func darker(componentDelta: CGFloat = 0.1) -> UIColor {
        return makeColor(componentDelta: -1*componentDelta)
    }
}

extension TimeInterval {
    
    func stringFormatted() -> String {
        var miliseconds = self.rounded(toPlaces: 1) * 10
        miliseconds = miliseconds.truncatingRemainder(dividingBy: 10)
        let interval = Int(self)
        let days = interval / 86400
        return String(format: "%2d", days)
    }
}

extension Date {
    
    func startOfMonth() -> Date {
        
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }

    func endOfMonth() -> String {
        
        let dateFormatter = DateFormatter.dateAndMonth
        let endDay = Calendar.current.date(byAdding: DateComponents(month: 0, day: 0), to: self.startOfMonth())!
        return dateFormatter.string(from: endDay)
    }
    
    func startOfPreviusDate() -> String {
        
        let dateFormatter = DateFormatter.dateAndMonth
        let endDay = Calendar.current.date(byAdding: DateComponents(month: -1, day: 1), to: self.startOfMonth())!
        return dateFormatter.string(from: endDay)
    }
    
    static func -(recent: Date, previous: Date) -> (month: Int?, day: Int?, hour: Int?, minute: Int?, second: Int?) {
        let day = Calendar.current.dateComponents([.day], from: previous, to: recent).day
        let month = Calendar.current.dateComponents([.month], from: previous, to: recent).month
        let hour = Calendar.current.dateComponents([.hour], from: previous, to: recent).hour
        let minute = Calendar.current.dateComponents([.minute], from: previous, to: recent).minute
        let second = Calendar.current.dateComponents([.second], from: previous, to: recent).second

        return (month: month, day: day, hour: hour, minute: minute, second: second)
    }
}

extension Collection {
    func splitInSubArrays(_ size: Int) -> [[Element]] {
        enumerated().reduce(into: [[Element]](repeating: [], count: size)) {
            $0[$1.offset % size].append($1.element)
        }
    }
}
