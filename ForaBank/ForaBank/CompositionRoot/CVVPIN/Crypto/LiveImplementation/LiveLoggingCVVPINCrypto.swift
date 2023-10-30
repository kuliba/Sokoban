//
//  LiveCVVPINCrypto.swift
//  ForaBank
//
//  Created by Igor Malyarov on 29.10.2023.
//

import ForaCrypto
import Foundation

struct LiveLoggingCVVPINCrypto {
    
    typealias PublicKey = P384KeyAgreementDomain.PublicKey
    typealias PrivateKey = P384KeyAgreementDomain.PrivateKey
    typealias RSAKeyPair = (publicKey: SecKey, privateKey: SecKey)
        
    let _generateP384KeyPair: () -> P384KeyAgreementDomain.KeyPair
    let _generateRSA4096BitKeyPair: () throws -> RSAKeyPair
    let _publicKeyData: (PublicKey) throws -> Data
    let _transportEncrypt: (Data) throws -> Data
    let _sharedSecret: (String, PrivateKey) throws -> Data
    
    let log: (String) -> Void
}

extension LiveLoggingCVVPINCrypto {
    
    func generateP384KeyPair() -> P384KeyAgreementDomain.KeyPair {
        
        let keyPair = _generateP384KeyPair()
        log("P384 Key Pair generated.")
        return keyPair
    }
}

extension LiveLoggingCVVPINCrypto {
    
    func publicKeyData(
        forPublicKey publicKey: PublicKey
    ) throws -> Data {
        
        try _publicKeyData(publicKey)
    }
    
    func transportEncrypt(data: Data) throws -> Data {
        
        do {
            let encrypted = try _transportEncrypt(data)
            log("Encryption with transport key success (\(encrypted.count)).")
            
            return encrypted
        } catch {
            log("Encryption with transport key failure: \(error).")
            throw error
        }
    }
}

/// Used if `AuthenticateWithPublicKeyService`
extension LiveLoggingCVVPINCrypto {
    
    func makeSharedSecret(
        from string: String,
        using privateKey: P384KeyAgreementDomain.PrivateKey
    ) throws -> Data {
        
        do {
            let sharedSecret = try _sharedSecret(string, privateKey)
            log("Shared Secret generation success (\(sharedSecret.count)).")
            
            return sharedSecret
        } catch {
            log("Shared Secret generation failure: \(error).")
            throw error
        }
    }
}

/// `ChangePINSecretJSON`
extension LiveLoggingCVVPINCrypto {
    
    func generateRSA4096BitKeyPair() throws -> RSAKeyPair {
        
        do {
            let rsaKeyPair = try _generateRSA4096BitKeyPair()
            log("RSAKeyPair generation success.")
            
            return rsaKeyPair
        } catch {
            log("RSAKeyPair generation failure: \(error).")
            throw error
        }
    }
    
    func signEncryptOTP(
        otp: String,
        privateKey: SecKey
    ) throws -> Data {
        
        let clientSecretOTP = try ForaCrypto.Crypto.signNoHash(
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
            let transportKey = try ForaCrypto.Crypto.transportKey()
            
            let encrypted = try ForaCrypto.Crypto.encrypt(
                data: data,
                withPublicKey: transportKey,
                algorithm: .rsaEncryptionRaw
            )
            log("Encrypted with transport public key: \(encrypted)")
            
            return encrypted
        } catch {
            log("Transport public key encryption error: \(error.localizedDescription)")
            throw error
        }
    }
    
    func x509Representation(
        publicKey: SecKey
    ) throws -> Data {
        
        let x509Representation = try ForaCrypto.Crypto.x509Representation(of: publicKey)
        log("x509Representation of \(publicKey) is \"\(x509Representation.base64EncodedString())\".")
        
        return x509Representation
    }
    
    func aesEncrypt(
        data: Data,
        sessionKey: SessionKey
    ) throws -> Data {
        
        do {
            let prefix = sessionKey.sessionKeyValue.prefix(32)
            
            let aes256CBC = try ForaCrypto.AES256CBC(key: prefix)
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
extension LiveLoggingCVVPINCrypto {
    
#warning("на bpmn схеме указано `Расшифровываем EVENT-ID открытым RSA-ключом клиента` и `Расшифровываем phone открытым RSA-ключом клиента`, но на стороне бэка шифрование производится открытым ключом переданным ранее -- ВАЖНО: ПОТЕНЦИАЛЬНА ОШИБКА - ПРОБУЮ РАСШИФРОВАТЬ ПРИВАТНЫМ КЛЮЧОМ")
    func rsaDecrypt(
        _ string: String,
        withPrivateKey privateKey: SecKey
    ) throws -> String {
        
        let data = try ForaCrypto.Crypto.decrypt(
            string,
            with: .rsaSignatureDigestPKCS1v15Raw,
            using: privateKey
        )
        
        guard let string = String(data: data, encoding: .utf8)
        else {
            throw DataToStringConversionError()
        }
        
        return string
    }
    
    struct DataToStringConversionError: Error {}
}
