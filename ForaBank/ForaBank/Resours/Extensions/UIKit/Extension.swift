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
            print(hexStringFromData(input: stringData as NSData))
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
            
            print("String to encrypt:\t\t\t\(stringToEncrypt)")

            let encryptedData: Data = try aes.encrypt(stringToEncrypt)
            print("String encrypted (base64):\t\(encryptedData.base64EncodedString())")
            
            let decryptedData: String = try aes.decrypt(encryptedData)
            print("String decrypted:\t\t\t\(decryptedData)")
            return encryptedData.base64EncodedString()
        } catch {
            print("Something went wrong: \(error)")
            return nil
        }
    }

}
