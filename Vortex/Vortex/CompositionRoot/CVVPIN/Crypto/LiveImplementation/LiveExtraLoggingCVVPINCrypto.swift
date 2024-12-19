//
//  LiveCVVPINCrypto.swift
//  ForaBank
//
//  Created by Igor Malyarov on 29.10.2023.
//

import ForaCrypto
import Foundation

struct LiveExtraLoggingCVVPINCrypto {
    
    typealias KeyPair = P384KeyAgreementDomain.KeyPair
    typealias PublicKey = P384KeyAgreementDomain.PublicKey
    typealias PrivateKey = P384KeyAgreementDomain.PrivateKey
    typealias RSAKeyPair = (publicKey: SecKey, privateKey: SecKey)
        
    private typealias Crypto = ForaCrypto.Crypto
    
    let log: (String) -> Void
}

extension LiveExtraLoggingCVVPINCrypto {
    
    func generateP384KeyPair() -> KeyPair {
        
        Crypto.generateP384KeyPair()
    }
}

extension LiveExtraLoggingCVVPINCrypto {
    
    func publicKeyData(
        forPublicKey publicKey: PublicKey
    ) throws -> Data {
        
        publicKey.derRepresentation
    }
    
    func transportEncrypt(data: Data) throws -> Data {
        
        try Crypto.transportEncrypt(
            data,
            padding: .PKCS1
        )
    }
}

/// Used if `AuthenticateWithPublicKeyService`
extension LiveExtraLoggingCVVPINCrypto {
    
    func makeSharedSecret(
        from string: String,
        using privateKey: P384KeyAgreementDomain.PrivateKey
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
}

/// `ChangePINSecretJSON`
extension LiveExtraLoggingCVVPINCrypto {
    
    func generateRSA4096BitKeyPair() throws -> RSAKeyPair {
        
        try Crypto.generateKeyPair(
            keyType: .rsa,
            keySize: .bits4096
        )
    }
    
    func signEncryptOTP(
        otp: String,
        privateKey: SecKey
    ) throws -> Data {
        
        let clientSecretOTP = try Crypto.signNoHash(
            .init(otp.utf8),
            withPrivateKey: privateKey,
            algorithm: .rsaSignatureDigestPKCS1v15Raw
        )
        log("Create \"clientSecretOTP\" (signed OTP): \(clientSecretOTP)")
        
        let procClientSecretOTP = try transportKeyEncrypt(
            clientSecretOTP
        )
        log("Create \"procClientSecretOTP\" (encrypted \"clientSecretOTP\"): \(procClientSecretOTP)")
        
        return procClientSecretOTP
    }
    
    func transportKeyEncrypt(_ data: Data) throws -> Data {
        
        do {
            let transportKey = try Crypto.transportKey()
            log("Loaded transport public key: \(transportKey)")
            
            let encrypted = try Crypto.encrypt(
                data: data,
                withPublicKey: transportKey,
                algorithm: .rsaEncryptionRaw
            )
            log("Encrypted with transport public key: \(encrypted)")
            
            return encrypted
        } catch {
            log("Transport public key encryption error: \(error).")
            throw error
        }
    }
    
    func x509Representation(
        publicKey: SecKey
    ) throws -> Data {
        
        try Crypto.x509Representation(of: publicKey)
    }
    
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
}

/// `ChangePINCrypto`
extension LiveExtraLoggingCVVPINCrypto {
    
#warning("на bpmn схеме указано `Расшифровываем EVENT-ID открытым RSA-ключом клиента` и `Расшифровываем phone открытым RSA-ключом клиента`, но на стороне бэка шифрование производится открытым ключом переданным ранее -- ВАЖНО: ПОТЕНЦИАЛЬНА ОШИБКА - ПРОБУЮ РАСШИФРОВАТЬ ПРИВАТНЫМ КЛЮЧОМ")
    func rsaDecrypt(
        _ string: String,
        withPrivateKey privateKey: SecKey
    ) throws -> String {
        
        let data = try Crypto.decrypt(
            string,
            with: .rsaSignatureDigestPKCS1v15Raw,
            using: privateKey
        )

        return try String(data: data, encoding: .utf8).get(orThrow: DataToStringConversionError())
    }
    
    struct DataToStringConversionError: Error {}
}
