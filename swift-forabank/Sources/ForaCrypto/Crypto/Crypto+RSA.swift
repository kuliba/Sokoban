//
//  Crypto+RSA.swift
//  
//
//  Created by Igor Malyarov on 24.08.2023.
//

import Foundation

public extension Crypto {
    
    static func rsaPKCS1Encrypt(
        data: Data,
        withPublicKey key: SecKey
    ) throws -> Data {
        
        try encrypt(data: data, withPublicKey: key, algorithm: .rsaEncryptionPKCS1)
    }
    
    static func encrypt(
        data: Data,
        withPublicKey key: SecKey,
        algorithm: SecKeyAlgorithm
    ) throws -> Data {
        
        var error: Unmanaged<CFError>? = nil
        guard let encrypted = SecKeyCreateEncryptedData(key, algorithm, data as CFData, &error) as Data?
        else {
            throw Error.encryptionFailure(error?.takeRetainedValue() as? Swift.Error)
        }
        
        return encrypted
    }
    
    // From ForaBank, modified
    static func encryptWithRSAKey(
        _ data: Data,
        publicKey key: SecKey,
        padding: SecPadding
    ) throws -> Data {
        
        let blockSize = SecKeyGetBlockSize(key)
        let maxChunkSize = blockSize - 11
        
        var decryptedDataAsArray = [UInt8](repeating: 0, count: data.count / MemoryLayout<UInt8>.size)
        (data as NSData).getBytes(&decryptedDataAsArray, length: data.count)
        
        var encryptedData = [UInt8](repeating: 0, count: 0)
        var idx = 0
        while (idx < decryptedDataAsArray.count ) {
            var idxEnd = idx + maxChunkSize
            if ( idxEnd > decryptedDataAsArray.count ) {
                idxEnd = decryptedDataAsArray.count
            }
            var chunkData = [UInt8](repeating: 0, count: maxChunkSize)
            for i in idx..<idxEnd {
                chunkData[i-idx] = decryptedDataAsArray[i]
            }
            
            var encryptedDataBuffer = [UInt8](repeating: 0, count: blockSize)
            var encryptedDataLength = blockSize
            
            let status = SecKeyEncrypt(key, padding, chunkData, idxEnd-idx, &encryptedDataBuffer, &encryptedDataLength)
            if (status != noErr) {
                throw Crypto.Error.encryptionFailed("Encryption failed: \(String(describing: SecCopyErrorMessageString(status, nil)))")
            }
            encryptedData += encryptedDataBuffer
            
            idx += maxChunkSize
        }
        
        return Data(bytes: UnsafePointer<UInt8>(encryptedData), count: encryptedData.count)
    }
    
    static func rsaPKCS1Decrypt(
        data: Data,
        withPrivateKey key: SecKey
    ) throws -> Data {
        
        try rsaDecrypt(data: data, withPrivateKey: key, algorithm: .rsaEncryptionPKCS1)
    }
    
    static func rsaDecrypt(
        data: Data,
        withPrivateKey key: SecKey,
        algorithm: SecKeyAlgorithm
    ) throws -> Data {
        
        var error: Unmanaged<CFError>? = nil
        guard let decrypted = SecKeyCreateDecryptedData(key, algorithm, data as CFData, &error) as Data?
        else {
            throw Error.decryptionFailure(error?.takeRetainedValue() as? Swift.Error)
        }
        
        return decrypted
    }
}
