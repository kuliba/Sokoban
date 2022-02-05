//
//  Decryptor.swift
//  ForaBank
//
//  Created by Max Gribov on 21.01.2022.
//

import Foundation

struct Decryptor: EncryptionDecryptor {
    
    let privateKey: SecKey
    var algorithm: SecKeyAlgorithm
    var chunkLength: Int = 128
    var decoder: JSONDecoder = JSONDecoder()
    
    func decrypt(_ data: Data) throws -> Data {
        
        guard SecKeyIsAlgorithmSupported(privateKey, .decrypt, algorithm) else {
            throw ECKeysProviderError.unableDecryptWithAlgorithm(algorithm)
        }
                
        var error: Unmanaged<CFError>?
        guard let decryptedData = SecKeyCreateDecryptedData(privateKey, algorithm, data as CFData, &error) as Data? else {
            throw ECKeysProviderError.decryptionFailed(error?.takeRetainedValue())
        }
        
        return decryptedData
    }
    
    func decryptBlob<T: Decodable>(_ data: Data) throws -> T {
        
        let decryptedData = try decrypt(data)
        
        return try decoder.decode(T.self, from: decryptedData)
    }

    func decryptChunked<T: Decodable>(_ data: Data) throws -> T {
        
        var offset: Int = 0
        var remainBytes = data.count
        var decryptedData = Data()

        repeat {
            
            let length = min(chunkLength, remainBytes)
            let chunk = data.subdata(in: offset..<(offset + length))
            let decrypteddChunk = try decrypt(chunk)
            decryptedData.append(decrypteddChunk)
            offset += length
            remainBytes -= length
            
        } while remainBytes > 0
        
        return try decoder.decode(T.self, from: decryptedData)
    }
}
