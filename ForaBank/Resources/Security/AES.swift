//
//  AES.swift
//  ForaBank
//
//  Created by Дмитрий on 06.05.2021.
//  Copyright © 2021 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation
import CommonCrypto

struct AES256 {
    
    private var key: Data
    private var iv: Data
    
    public init(key: Data, iv: Data) throws {
        guard key.count == kCCKeySizeAES256 else {
            throw Error.badKeyLength
        }
        guard iv.count == kCCBlockSizeAES128 else {
            throw Error.badInputVectorLength
        }
        self.key = key
        self.iv = iv
    }
    
    enum Error: Swift.Error {
        case keyGeneration(status: Int)
        case cryptoFailed(status: CCCryptorStatus)
        case badKeyLength
        case badInputVectorLength
    }

    func encrypt(_ digest: Data) throws -> Data {
        return try crypt(input: digest, operation: CCOperation(kCCEncrypt))
    }
    
    func decrypt(_ encrypted: Data) throws -> Data {
        return try crypt(input: encrypted, operation: CCOperation(kCCDecrypt))
    }
    
    private func crypt(input: Data, operation: CCOperation) throws -> Data {
        var outLength = Int(0)
        var outBytes = [UInt8](repeating: 0, count: input.count + kCCBlockSizeAES128)
        var status: CCCryptorStatus = CCCryptorStatus(kCCSuccess)
        input.withUnsafeBytes { (encryptedBytes: UnsafePointer<UInt8>!) -> () in
            iv.withUnsafeBytes { (ivBytes: UnsafePointer<UInt8>!) in
                key.withUnsafeBytes { (keyBytes: UnsafePointer<UInt8>!) -> () in
                    status = CCCrypt(operation,
                                     CCAlgorithm(kCCAlgorithmAES),            // algorithm
                                     CCOptions(kCCOptionPKCS7Padding),           // options
                                     keyBytes,                                   // key
                                     key.count,                                  // keylength
                                     ivBytes,                                    // iv
                                     encryptedBytes,                             // dataIn
                                     input.count,                                // dataInLength
                                     &outBytes,                                  // dataOut
                                     outBytes.count,                             // dataOutAvailable
                                     &outLength)                                 // dataOutMoved
                }
            }
        }
        
        guard status == kCCSuccess else {
            throw Error.cryptoFailed(status: status)
        }
        var newData = Data()
        newData.append(iv)
        newData.append(Data(bytes: UnsafePointer<UInt8>(outBytes), count: outLength))
        return newData
    }
    
//    static func encrytedAes(string: String?, input: Data)-> String?{
//        let keyString        = input
//        let keyData: NSData! = keyString as NSData
//        print("keyLength   = \(keyData.length), keyData   = \(keyData)")
//
//        let message       = string
//        let data: NSData! = (message as! NSString).data(using: String.Encoding.utf8.rawValue) as NSData?
//        print("data length = \(data.length), data      = \(data)")
//
//        let cryptData    = NSMutableData(length: Int(data.length) + kCCBlockSizeAES128)!
//
//        let keyLength              = size_t(kCCKeySizeAES256)
//        let operation: CCOperation = UInt32(kCCEncrypt)
//        let algoritm:  CCAlgorithm = UInt32(kCCAlgorithmAES128)
//        let options:   CCOptions   = UInt32(kCCOptionECBMode + kCCOptionPKCS7Padding)
//
//        var numBytesEncrypted :size_t = 0
//
//        var cryptStatus = CCCrypt(operation,
//            algoritm,
//            options,
//            keyData.bytes, keyLength,
//            nil,
//            data.bytes, data.length,
//            cryptData.mutableBytes, cryptData.length,
//            &numBytesEncrypted)
//
//        if UInt32(cryptStatus) == UInt32(kCCSuccess) {
//            cryptData.length = Int(numBytesEncrypted)
//            print("cryptLength = \(numBytesEncrypted), cryptData = \(cryptData)")
//
//            // Not all data is a UTF-8 string so Base64 is used
//            let base64cryptString = cryptData.base64EncodedString(options: .lineLength64Characters)
//            print("base64cryptString = \(base64cryptString)")
//            return base64cryptString
//        } else {
//            print("Error: \(cryptStatus)")
//        }
//        return nil
//    }
    
    static func createKey(password: Data) throws -> Data {
        let length = kCCKeySizeAES256
        var status = Int32(0)
        var derivedBytes = [UInt8](repeating: 0, count: length)
        password.withUnsafeBytes { (passwordBytes: UnsafePointer<Int8>!) in
//            salt.withUnsafeBytes { (saltBytes: UnsafePointer<UInt8>!) in
//                status = CCKeyDerivationPBKDF(CCPBKDFAlgorithm(kCCPBKDF2),                  // algorithm
//                                              passwordBytes,                                // password
//                                              password.count,                               // passwordLen
//                                              saltBytes,                                    // salt
//                                              salt.count,                                   // saltLen
//                                              CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA1),   // prf
//                                              10000,                                        // rounds
//                                              &derivedBytes,                                // derivedKey
//                                              length)                                       // derivedKeyLen
//            }
        }
        guard status == 0 else {
            throw Error.keyGeneration(status: Int(status))
        }
        return Data(bytes: UnsafePointer<UInt8>(derivedBytes), count: length)
    }
    
    static func randomIv() -> Data {
        return randomData(length: kCCBlockSizeAES128)
    }
    
    static func randomSalt() -> Data {
        return randomData(length: 8)
    }
    
    static func randomData(length: Int) -> Data {
        var data = Data(count: length)
        let status = data.withUnsafeMutableBytes { mutableBytes in
            SecRandomCopyBytes(kSecRandomDefault, length, mutableBytes)
        }
        assert(status == Int32(0))
        return data
    }
}
