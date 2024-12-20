//
//  LiveCVVPINCrypto.swift
//  Vortex
//
//  Created by Igor Malyarov on 29.10.2023.
//

import CryptoKit
import VortexCrypto
import Foundation

struct LiveExtraLoggingCVVPINCrypto {
    
    typealias ECDHPublicKey = ECDHDomain.PublicKey
    typealias ECDHPrivateKey = ECDHDomain.PrivateKey
    typealias ECDHKeyPair = ECDHDomain.KeyPair
    
    typealias RSAPublicKey = RSADomain.PublicKey
    typealias RSAPrivateKey = RSADomain.PrivateKey
    typealias RSAKeyPair = RSADomain.KeyPair
    
    private typealias Crypto = VortexCrypto.Crypto
    
    typealias Log = (String, StaticString, UInt) -> Void
    
    let transportKey: () throws -> TransportKey
    let processingKey: () throws -> ProcessingKey
    let log: Log
}
    
extension LiveExtraLoggingCVVPINCrypto {

    struct TransportKey {
        
        let key: SecKey
    }

    struct ProcessingKey {
        
        let key: SecKey
    }
}

extension LiveExtraLoggingCVVPINCrypto {
    
    // MARK: - Transport & Processing Public Key Domain
    
    func transportEncryptWithPadding(data: Data) throws -> Data {
        
        try Crypto.encryptWithRSAKey(
            data,
            publicKey: transportKey().key,
            padding: .PKCS1
        )
    }
    
    func transportEncryptNoPadding(data: Data) throws -> Data {
        
        try Crypto.encrypt(
            data: data,
            withPublicKey: transportKey().key,
            algorithm: .rsaEncryptionRaw
        )
    }
    
    func processingEncryptWithPadding(data: Data) throws -> Data {
        
        try Crypto.encryptWithRSAKey(
            data,
            publicKey: processingKey().key,
            padding: .PKCS1
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
        
        return (privateKey: .init(key: privateKey),
                publicKey: .init(key: publicKey))
    }
    
    func hashSignVerify(
        string: String,
        publicKey: RSAPublicKey,
        privateKey: RSAPrivateKey
    ) throws -> Data {
        
        let signedData = try sha256Sign(
            data: .init(string.utf8),
            withPrivateKey: privateKey
        )
        
#warning("restore verify")
        // verify (not used in output)
//        let signature = try createSignature(
//            forSignedData: signedData,
//            withPrivateKey: privateKey
//        )
//        try verify(
//            signedData: signedData,
//            signature: signature,
//            withPrivateKey: publicKey
//        )
        
        return signedData
    }
    
    /// `ChangePINCrypto`
    /// - Note: на bpmn схеме указано `Расшифровываем EVENT-ID открытым RSA-ключом клиента` и `Расшифровываем phone открытым RSA-ключом клиента`, но на стороне бэка шифрование производится `открытым` ключом переданным ранее -- поэтому метод расшифровывает, используя `приватный` ключ.
    func rsaDecrypt(
        _ string: String,
        withPrivateKey privateKey: RSAPrivateKey
    ) throws -> String {
        
        let data = try Crypto.decrypt(
            string,
            with: .rsaEncryptionPKCS1,
            using: privateKey.key
        )
        
        return try String(data: data, encoding: .utf8).get(orThrow: DataToStringConversionError())
    }
    
    struct DataToStringConversionError: Error {}
    
    /// Follows the `PKCS#1 v1.5` standard and adds padding.
    func sha256Sign(
        data: Data,
        withPrivateKey privateKey: RSAPrivateKey
    ) throws -> Data {
        
        try Crypto.signNoHash(
            data,
            withPrivateKey: privateKey.key,
            algorithm: .rsaSignatureDigestPKCS1v15SHA256
        )
    }
    
    /// Signs the message digest directly without any additional padding. Digest is created using SHA256.
    func sign(
        data: Data,
        withPrivateKey privateKey: RSAPrivateKey
    ) throws -> Data {
        
        try Crypto.sign(
            data,
            withPrivateKey: privateKey.key,
            algorithm: .rsaSignatureDigestPKCS1v15SHA256
        )
    }

    /// Signs the message digest directly without any additional padding.
    /// Used in `clientSecretOTP`
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
        
        let prefix32 = sessionKey.sessionKeyValue.prefix(32)
        let aes256CBC = try AES256CBC(key: prefix32)
        let encrypted = try aes256CBC.encrypt(data)
        
        return encrypted
    }
    
    // MARK: - Hash
    
    func sha256Hash(_ data: Data) -> Data {
        
        SHA256
            .hash(data: data)
            .withUnsafeBytes { Data($0) }
    }
}

// MARK: - HashSignVerify

private extension LiveExtraLoggingCVVPINCrypto {
    
    typealias SignedData = Data
    
    func createSignature(
        forSignedData signedData: SignedData,
        withPrivateKey privateKey: RSAPrivateKey
    ) throws -> Data {
        
        do {
            return try Crypto.createSignature(
                for: signedData,
                usingPrivateKey: privateKey.key,
                algorithm: .rsaSignatureRaw
            )
        } catch {
            log("Signature creation failure: \(error).", #file, #line)
            throw error
        }
    }
    
    typealias Signature = Data
    
    func verify(
        signedData: SignedData,
        signature: Signature,
        withPrivateKey publicKey: RSAPublicKey
    ) throws {
        
        do {
            guard signature.count == 512
            else {
                throw VerifyError.signatureSizeNot512
            }
            
            let result = try Crypto.verify(
                signedData,
                withPublicKey: publicKey.key,
                signature: signature,
                algorithm: .rsaSignatureDigestPKCS1v15SHA256
            )
            
            if !result { throw VerifyError.verificationFailure }
        } catch {
            log("Signature verification failure: \(error).", #file, #line)
            throw error
        }
    }
    
    enum VerifyError: Error {
        
        case signatureSizeNot512
        case verificationFailure
    }
}
