//
//  Encryptor.swift
//  ForaBank
//
//  Created by Max Gribov on 21.01.2022.
//

import Foundation

struct Encryptor: EncryptionEncryptor {
    
    let publicKey: SecKey
    var algorithm: SecKeyAlgorithm
    var chunkLength: Int = 128
    var encoder: JSONEncoder = JSONEncoder()
    
    func encrypt(_ data: Data) throws -> Data {
        
        guard SecKeyIsAlgorithmSupported(publicKey, .encrypt, algorithm) else {
            throw ECKeysProviderError.unableEncryptWithAlgorithm(algorithm)
        }
        
        var error: Unmanaged<CFError>?
        guard let encryptedData = SecKeyCreateEncryptedData(publicKey, algorithm, data as CFData, &error) as Data? else {
            throw ECKeysProviderError.encryptionFailed(error?.takeRetainedValue())
        }
        
        return encryptedData
    }
    
    func encryptBlob<T: Encodable>(_ data: T) throws -> Data {
        
        let encodedData = try encoder.encode(data)
        
        return try encrypt(encodedData)
    }
    
    func encryptChunked<T: Encodable>(_ data: T) throws -> Data {
        
        let encodedData = try encoder.encode(data)

        var offset: Int = 0
        var remainBytes = encodedData.count
        var encryptedData = Data()
        
        repeat {
            
            let length = min(chunkLength, remainBytes)
            let chunk = encodedData.subdata(in: offset..<(offset + length))
            let encyptedChunk = try encrypt(chunk)
            encryptedData.append(encyptedChunk)
            offset += length
            remainBytes -= length
            
        } while remainBytes > 0
        
        return encryptedData
    }
}
