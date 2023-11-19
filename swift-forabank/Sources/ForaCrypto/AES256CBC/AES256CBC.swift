//
//  AES256CBC.swift
//  
//
//  Created by Igor Malyarov on 29.08.2023.
//

import CommonCrypto
import Foundation

/// AES with CBC mode.
public struct AES256CBC {
    
    private var key: Data
    private var iv: Data
    
    public init(
        key: Data,
        iv: Data = AES256CBC.randomIV()
    ) throws {
        
        guard key.count == kCCKeySizeAES256
        else {
            throw Error.badKeyLength
        }
        
        guard iv.count == kCCBlockSizeAES128
        else {
            throw Error.badInputVectorLength
        }
        
        self.key = key
        self.iv = iv
    }
    
    public enum Error: Swift.Error {
        
        case keyGeneration(status: Int)
        case cryptoFailed(status: CCCryptorStatus)
        case badKeyLength
        case badInputVectorLength
    }
    
    public func encrypt(_ digest: Data) throws -> Data {
        
        let data = try crypt(
            input: digest,
            operation: CCOperation(kCCEncrypt)
        )
        
        return iv + data
    }
    
    public func decrypt(_ encrypted: Data) throws -> Data {
        
        var data = try crypt(
            input: encrypted,
            operation: CCOperation(kCCDecrypt)
        )
        data.removeFirst(iv.count)
        
        return data
    }
    
    private func crypt(
        input: Data,
        operation: CCOperation
    ) throws -> Data {
        
        var outLength = Int(0)
        var outBytes = [UInt8](repeating: 0, count: input.count + kCCBlockSizeAES128)
        var status: CCCryptorStatus = CCCryptorStatus(kCCSuccess)
        
        input.withUnsafeBytes { (encryptedBytes: UnsafePointer<UInt8>!) -> () in
            iv.withUnsafeBytes { (ivBytes: UnsafePointer<UInt8>!) in
                key.withUnsafeBytes { (keyBytes: UnsafePointer<UInt8>!) -> () in
                    status = CCCrypt(
                        operation,
                        CCAlgorithm(kCCAlgorithmAES128),            // algorithm
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
        
        return Data(bytes: UnsafePointer<UInt8>(outBytes), count: outLength)
    }
    
    public static func createKey(
        password: Data,
        salt: Data = AES256CBC.randomSalt()
    ) throws -> Data {
        let length = kCCKeySizeAES256
        var status = Int32(0)
        var derivedBytes = [UInt8](repeating: 0, count: length)
        password.withUnsafeBytes { (passwordBytes: UnsafePointer<Int8>!) in
            salt.withUnsafeBytes { (saltBytes: UnsafePointer<UInt8>!) in
                status = CCKeyDerivationPBKDF(
                    CCPBKDFAlgorithm(kCCPBKDF2),                  // algorithm
                    passwordBytes,                                // password
                    password.count,                               // passwordLen
                    saltBytes,                                    // salt
                    salt.count,                                   // saltLen
                    CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA1),   // prf
                    10000,                                        // rounds
                    &derivedBytes,                                // derivedKey
                    length)                                       // derivedKeyLen
            }
        }
        
        guard status == 0 else {
            throw Error.keyGeneration(status: Int(status))
        }
        
        return Data(bytes: UnsafePointer<UInt8>(derivedBytes), count: length)
    }
    
    public static func randomIV() -> Data {
        
        randomData(length: kCCBlockSizeAES128)
    }
    
    public static func randomSalt() -> Data {
        
        randomData(length: 8)
    }
    
    public static func randomData(length: Int) -> Data {
        var data = Data(count: length)
        let status = data.withUnsafeMutableBytes { mutableBytes in
            SecRandomCopyBytes(kSecRandomDefault, length, mutableBytes)
        }
        assert(status == Int32(0))
        
        return data
    }
}
