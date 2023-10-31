//
//  LiveCVVPINCrypto.swift
//  ForaBank
//
//  Created by Igor Malyarov on 29.10.2023.
//

import CryptoKit
import ForaCrypto
import Foundation

struct LiveExtraLoggingCVVPINCrypto {
    
    typealias ECDHPublicKey = ECDHDomain.PublicKey
    typealias ECDHPrivateKey = ECDHDomain.PrivateKey
    typealias ECDHKeyPair = ECDHDomain.KeyPair
    
    typealias RSAPublicKey = RSADomain.PublicKey
    typealias RSAPrivateKey = RSADomain.PrivateKey
    typealias RSAKeyPair = RSADomain.KeyPair
    
    private typealias Crypto = ForaCrypto.Crypto
    
    let log: (String) -> Void
}

extension LiveExtraLoggingCVVPINCrypto {
    
    // MARK: - Transport & Processing Key Domain

    func transportEncryptWithPadding(data: Data) throws -> Data {
        
        try Crypto.encryptWithRSAKey(
            data,
            publicKey: Crypto.transportKey(),
            padding: .PKCS1
        )
    }
    
    func transportEncryptNoPadding(data: Data) throws -> Data {
        
        try Crypto.encrypt(
            data: data,
            withPublicKey: Crypto.transportKey(),
            algorithm: .rsaEncryptionRaw
        )
    }
    
    func processingEncrypt(data: Data) throws -> Data {
        
        try Crypto.encrypt(
            data: data,
            withPublicKey: Crypto.processingKey(),
            algorithm: .rsaEncryptionRaw
        )
    }

    // MARK: - ECDH Domain
    
    func generateECDHKeyPair() -> ECDHKeyPair {
        
        Crypto.generateP384KeyPair()
    }
    
    /// Used if `AuthenticateWithPublicKeyService`
    func extractSharedSecret(
        from string: String,
        using privateKey: ECDHPrivateKey
    ) throws -> Data {
        
        let serverPublicKey = try Crypto.transportDecryptP384PublicKey(
            from: string
        )
        let sharedSecret = try Crypto.sharedSecret(
            privateKey: privateKey,
            publicKey: serverPublicKey
        )
        
        return sharedSecret
    }
    
    func publicKeyData(
        forPublicKey publicKey: ECDHPublicKey
    ) throws -> Data {
        
        publicKey.derRepresentation
    }
    
    // MARK: - RSA Domain
    
    /// `ChangePINSecretJSON`
    func generateRSA4096BitKeyPair() throws -> RSAKeyPair {
        
        let (publicKey, privateKey) = try Crypto.generateKeyPair(
            keyType: .rsa,
            keySize: .bits4096
        )
        
        return (privateKey: .init(key: privateKey), publicKey: .init(key: publicKey))
    }
    
    /// `ChangePINCrypto`
#warning("на bpmn схеме указано `Расшифровываем EVENT-ID открытым RSA-ключом клиента` и `Расшифровываем phone открытым RSA-ключом клиента`, но на стороне бэка шифрование производится открытым ключом переданным ранее -- ВАЖНО: ПОТЕНЦИАЛЬНА ОШИБКА - ПРОБУЮ РАСШИФРОВАТЬ ПРИВАТНЫМ КЛЮЧОМ")
    func rsaDecrypt(
        _ string: String,
        withPrivateKey privateKey: RSAPrivateKey
    ) throws -> String {
        
        let data = try Crypto.decrypt(
            string,
            with: .rsaEncryptionPKCS1,
            // with: .rsaSignatureDigestPKCS1v15Raw,
            using: privateKey.key
        )
        
        return try String(data: data, encoding: .utf8).get(orThrow: DataToStringConversionError())
    }
    
    struct DataToStringConversionError: Error {}
    
    func signNoHash(
        _ data: Data,
        withPrivateKey privateKey: RSAPrivateKey
    ) throws -> Data {
        
        try Crypto.signNoHash(
            data,
            withPrivateKey: privateKey.key,
            algorithm: .rsaSignatureDigestPKCS1v15Raw
        )
    }
     
    func x509Representation(
        publicKey: RSAPublicKey
    ) throws -> Data {
        
        try Crypto.x509Representation(of: publicKey.key)
    }
    
    // MARK: - AES
    
    func aesEncrypt(
        data: Data,
        sessionKey: SessionKey
    ) throws -> Data {
        
        do {
            let prefix = sessionKey.sessionKeyValue.prefix(32)
            
            let aes256CBC = try AES256CBC(key: prefix)
            log("Create AES256CBC with key prefix (\(prefix.count)) \"\(prefix.base64EncodedString())\"")
            
            do {
                let encrypted = try aes256CBC.encrypt(data)
                log("AES encrypted data (\(encrypted.count)) base64 (\(encrypted.base64EncodedString().count)): \"\(encrypted.base64EncodedString())\".")
                
                return encrypted
            } catch {
                log("AES Encryption Failure: \(error).")
                throw error
            }
        } catch {
            log("AES Encryption Failure: \(error).")
            throw error
        }
    }
    
    // MARK: - Hash
    
    func sha256Hash(_ data: Data) -> Data {
        
        SHA256
            .hash(data: data)
            .withUnsafeBytes { Data($0) }
    }
}
