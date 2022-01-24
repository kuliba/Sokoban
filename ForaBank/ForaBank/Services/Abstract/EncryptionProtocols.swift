//
//  Encryption.swift
//  ForaBank
//
//  Created by Max Gribov on 23.01.2022.
//

import Foundation
import Security

protocol EncryptionKeysProvider {
    
    func getPublicKey() throws -> SecKey
    func getPrivateKey() throws -> SecKey
    func deletePrivateKey() throws
    
    func publicKeyData() throws -> Data
    func publicKey(from data: Data) throws -> SecKey
    var algorithm: SecKeyAlgorithm { get }
}

protocol EncryptionEncryptor {
    
    func encrypt(_ data: Data) throws -> Data
    func encryptBlob<T: Encodable>(_ data: T) throws -> Data
    func encryptChunked<T: Encodable>(_ data: T) throws -> Data
}

protocol EncryptionDecryptor {
    
    func decrypt(_ data: Data) throws -> Data
    func decryptBlob<T: Decodable>(_ data: Data) throws -> T
    func decryptChunked<T: Decodable>(_ data: Data) throws -> T
}
