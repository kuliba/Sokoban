//
//  LoggingCVVPINCryptoDecorator.swift
//  ForaBank
//
//  Created by Igor Malyarov on 29.10.2023.
//

import ForaCrypto
import Foundation

final class LoggingCVVPINCryptoDecorator {
    
    private let decoratee: CVVPINCrypto
    private let log: (String) -> Void
    
    init(
        decoratee: CVVPINCrypto,
        log: @escaping (String) -> Void
    ) {
        self.decoratee = decoratee
        self.log = log
    }
}

extension LoggingCVVPINCryptoDecorator: CVVPINCrypto {
    
    // MARK: - Transport Key Domain
    
    func transportEncrypt(data: Data) throws -> Data {
        
        do {
            let encrypted = try decoratee.transportEncrypt(data: data)
            log("Encrypted with transport key (\(encrypted.count)).")
            
            return encrypted
        } catch {
            log("Encrypted with transport failure: \(error).")
            throw error
        }
    }
    
    func transportKeyEncrypt(_ data: Data) throws -> Data {
        
        do {
            let encrypted = try decoratee.transportKeyEncrypt(data)
            log("Encrypted with transport public key: \(encrypted)")
            
            return encrypted
        } catch {
            log("Transport public key encryption error: \(error).")
            throw error
        }
    }
    
    // MARK: - ECDH Domain
    
    func generateECDHKeyPair() -> ECDHKeyPair {
        
        let keyPair = decoratee.generateECDHKeyPair()
        log("Generated P384 Key Pair.")
        
        return keyPair
    }
    
    func extractSharedSecret(
        from string: String,
        using privateKey: ECDHPrivateKey
    ) throws -> Data {
        
        do {
            let sharedSecret = try decoratee.extractSharedSecret(
                from: string,
                using: privateKey
            )
            log("Shared Secret generation success (\(sharedSecret.count)).")
            
            return sharedSecret
        } catch {
            log("Shared Secret creation failure: \(error)")
            throw error
        }
    }
    
    func publicKeyData(
        forPublicKey publicKey: ECDHPublicKey
    ) throws -> Data {
        
        do {
            let keyData = try decoratee.publicKeyData(forPublicKey: publicKey)
            log("PublicKey data created (\(keyData.count)).")
            
            return keyData
        } catch {
            log("PublicKey data creation failure \(error).")
            throw error
        }
    }
    
    // MARK: - RSA Domain
    
    func generateRSA4096BitKeyPair() throws -> RSAKeyPair {
        
        do {
            let rsaKeyPair = try decoratee.generateRSA4096BitKeyPair()
            log("RSAKeyPair generation success \(rsaKeyPair)")
            
            return rsaKeyPair
        } catch {
            log("RSAKeyPair generation failure: \(error).")
            throw error
        }
    }
    
    func rsaDecrypt(
        _ string: String,
        withPrivateKey privateKey: RSAPrivateKey
    ) throws -> String {
        
        do {
            let string = try decoratee.rsaDecrypt(string, withPrivateKey: privateKey)
            log("String decryption success: \"\(string)\"")
            
            return string
        } catch {
            log("String decryption failure: \(error).")
            throw error
        }
    }
    
    func signEncryptOTP(
        otp: String,
        privateKey: RSAPrivateKey
    ) throws -> Data {
        
        do {
            let signedEncryptedOTP = try decoratee.signEncryptOTP(
                otp: otp,
                privateKey: privateKey
            )
            log("Create \"signedEncryptedOTP\": \(signedEncryptedOTP)")
            
            return signedEncryptedOTP
        } catch {
            log("Sign encryted OPT failure: \(error).")
            throw error
        }
    }
    
    func x509Representation(
        publicKey: RSAPublicKey
    ) throws -> Data {
        
        do {
            let x509Representation = try decoratee.x509Representation(
                publicKey: publicKey
            )
            log("x509Representation of \(publicKey) is \"\(x509Representation.base64EncodedString())\".")
            
            return x509Representation
        } catch {
            log("x509Representation failure: \(error).")
            throw error
        }
    }
    
    // MARK: - AES
    
    func aesEncrypt(
        data: Data,
        sessionKey: SessionKey
    ) throws -> Data {
        
        do {
            let encrypted = try decoratee.aesEncrypt(
                data: data,
                sessionKey: sessionKey
            )
            log("AES encrypted data (\(encrypted.count)) base64 (\(encrypted.base64EncodedString().count)): \"\(encrypted.base64EncodedString())\".")
            
            return encrypted
        } catch {
            log("AES Encryption Failure: \(error).")
            throw error
        }
    }
}
