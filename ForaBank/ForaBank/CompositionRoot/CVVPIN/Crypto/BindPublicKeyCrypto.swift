//
//  BindPublicKeyCrypto.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.10.2023.
//

import ForaCrypto
import Foundation

// based on SecKeySwaddleCryptographer
#warning("refactor as ForaCrypto extension (?)")
enum BindPublicKeyCrypto {
    
    static func log(_ message: String) {
        
        LoggerAgent.shared.log(level: .debug, category: .crypto, message: message)
    }
    
    static func generateRSA4096BitKeyPair(
    ) throws -> (privateKey: SecKey, publicKey: SecKey)  {
        
        do {
            let (privateKey, publicKey) = try ForaCrypto.Crypto.createRandomSecKeys(
                keyType: .rsa,
                keySize: .bits4096
            )
            log("Generated key pair \((privateKey, publicKey))")
            return (privateKey, publicKey)
        } catch {
            log("Key pair generation failure: \(error).")
            throw error
        }
    }
    
    static func signEncryptOTP(
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
    
    static func transportKeyEncrypt(
        _ data: Data
    ) throws -> Data {
        
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
    
    static func x509Representation(
        publicKey: SecKey
    ) throws -> Data {
        
        let x509Representation = try ForaCrypto.Crypto.x509Representation(of: publicKey)
        log("x509Representation of \(publicKey) is \"\(x509Representation.base64EncodedString())\".")

        return x509Representation
    }
    
    static func aesEncrypt(
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
