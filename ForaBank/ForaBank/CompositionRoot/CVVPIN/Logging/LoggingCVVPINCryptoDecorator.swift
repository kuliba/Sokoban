//
//  LoggingCVVPINCryptoDecorator.swift
//  Vortex
//
//  Created by Igor Malyarov on 29.10.2023.
//

import VortexCrypto
import Foundation

final class LoggingCVVPINCryptoDecorator {
    
    typealias Log = (LoggerAgentLevel, String, StaticString, UInt) -> Void

    private let decoratee: CVVPINCrypto
    private let log: Log
    
    init(
        decoratee: CVVPINCrypto,
        log: @escaping Log
    ) {
        self.decoratee = decoratee
        self.log = log
    }
}

extension LoggingCVVPINCryptoDecorator: CVVPINCrypto {
    
    // MARK: - Transport & Processing Public Key Domain

    func transportEncryptWithPadding(data: Data) throws -> Data {
        
        do {
            let encrypted = try decoratee.transportEncryptWithPadding(data: data)
            log(.debug, "Encrypt \(String(data: data, encoding: .utf8) ?? "n/a") with padding using transport public key success (\(encrypted.count)).", #file, #line)
            
            return encrypted
        } catch {
            log(.error, "Encrypt with padding using transport public key failure: \(error).", #file, #line)
            throw error
        }
    }
    
    func transportEncryptNoPadding(data: Data) throws -> Data {
        
        do {
            let encrypted = try decoratee.transportEncryptNoPadding(data: data)
            log(.debug, "Encrypt \(String(data: data, encoding: .utf8) ?? "n/a") without padding using transport public key success (\(encrypted.count)).", #file, #line)
            
            return encrypted
        } catch {
            log(.error, "Encrypt without padding using transport public key failure: \(error).", #file, #line)
            throw error
        }
    }
    
    func processingEncryptWithPadding(data: Data) throws -> Data {
        
        do {
            let encrypted = try decoratee.processingEncryptWithPadding(data: data)
            log(.debug, "Encrypt \(String(data: data, encoding: .utf8) ?? "n/a") using processing public key success (\(encrypted.count)).", #file, #line)
            
            return encrypted
        } catch {
            log(.error, "Encrypt \(String(data: data, encoding: .utf8) ?? "n/a") using processing public key failure: \(error).", #file, #line)
            throw error
        }
    }

    // MARK: - ECDH Domain
    
    func generateECDHKeyPair() -> ECDHKeyPair {
        
        let keyPair = decoratee.generateECDHKeyPair()
        log(.debug, "Generated P384 Key Pair.", #file, #line)
        
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
            log(.debug, "Shared Secret extraction success (\(sharedSecret.count)).", #file, #line)
            
            return sharedSecret
        } catch {
            log(.error, "Shared Secret extraction failure: \(error).", #file, #line)
            throw error
        }
    }
    
    func publicKeyData(
        forPublicKey publicKey: ECDHPublicKey
    ) throws -> Data {
        
        do {
            let keyData = try decoratee.publicKeyData(forPublicKey: publicKey)
            log(.debug, "PublicKey data representation created (\(keyData.count)).", #file, #line)
            
            return keyData
        } catch {
            log(.error, "PublicKey data representation creation failure \(error).", #file, #line)
            throw error
        }
    }
    
    // MARK: - RSA Domain
    
    func generateRSA4096BitKeyPair() throws -> RSAKeyPair {
        
        do {
            let rsaKeyPair = try decoratee.generateRSA4096BitKeyPair()
            log(.debug, "RSA Key Pair generation success \(rsaKeyPair).", #file, #line)
            
            return rsaKeyPair
        } catch {
            log(.error, "RSA Key Pair generation failure: \(error).", #file, #line)
            throw error
        }
    }
    
    func hashSignVerify(
        string: String,
        publicKey: RSAPublicKey,
        privateKey: RSAPrivateKey
    ) throws -> Data {
        
        do {
            let data = try decoratee.hashSignVerify(
                string: string,
                publicKey: publicKey,
                privateKey: privateKey
            )
            log(.debug, "hashSignVerify success for \"\(string)\".", #file, #line)
            
            return data
        } catch {
            log(.error, "hashSignVerify failure: \(error) for \"\(string)\".", #file, #line)
            throw error
        }
    }
    
    func rsaDecrypt(
        _ string: String,
        withPrivateKey privateKey: RSAPrivateKey
    ) throws -> String {
        
        do {
            let string = try decoratee.rsaDecrypt(string, withPrivateKey: privateKey)
            log(.debug, "String decryption success: \"\(string)\"", #file, #line)
            
            return string
        } catch {
            log(.error, "String decryption failure: \(error).", #file, #line)
            throw error
        }
    }
    
    /// Signs the message digest directly without any additional padding. Digest is created using SHA256.
    func sign(
        data: Data,
        withPrivateKey privateKey: RSAPrivateKey
    ) throws -> Data {
        
        do {
            let signed = try decoratee.sign(
                data: data,
                withPrivateKey: privateKey
            )
            log(.debug, "Sign with SHA256 digest success (\(signed.count)), provided data: \"\(String(data: data, encoding: .utf8) ?? "n/a")\".", #file, #line)
            
            return signed
        } catch {
            log(.error, "Sign with SHA256 digest failure: \(error), provided data: \"\(String(data: data, encoding: .utf8) ?? "n/a")\".", #file, #line)
            throw error
        }
    }
    
    /// Follows the `PKCS#1 v1.5` standard and adds padding.
    func sha256Sign(
        data: Data,
        withPrivateKey privateKey: RSAPrivateKey
    ) throws -> Data {
        
        do {
            let signed = try decoratee.sha256Sign(
                data: data,
                withPrivateKey: privateKey
            )
            log(.debug, "SHA256 sign success (\(signed.count)), provided data: \"\(String(data: data, encoding: .utf8) ?? "n/a")\".", #file, #line)
            
            return signed
        } catch {
            log(.error, "SHA256 sign failure: \(error), provided data: \"\(String(data: data, encoding: .utf8) ?? "n/a")\".", #file, #line)
            throw error
        }
    }
    
    /// Signs the message digest directly without any additional padding.
    /// Used in `clientSecretOTP`
    func signNoHash(
        _ data: Data,
        withPrivateKey privateKey: RSAPrivateKey
    ) throws -> Data {
        
        do {
            let signed = try decoratee.signNoHash(
                data,
                withPrivateKey: privateKey
            )
            log(.debug, "Signing success (\(signed)) for provided data: \"\(String(data: data, encoding: .utf8) ?? "n/a")\".", #file, #line)
            
            return signed
        } catch {
            log(.error, "Signing failure: \(error) for data \"\(String(data: data, encoding: .utf8) ?? "n/a")\".", #file, #line)
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
            log(.debug, "x509Representation of \(publicKey) is \"\(x509Representation.base64EncodedString())\".", #file, #line)
            
            return x509Representation
        } catch {
            log(.error, "x509Representation failure: \(error).", #file, #line)
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
            log(.debug, "AES encrypted (\(encrypted.count)) provided data: \"\(String(data: data, encoding: .utf8) ?? "n/a")\".", #file, #line)
            
            return encrypted
        } catch {
            log(.error, "AES Encryption Failure: \(error).", #file, #line)
            throw error
        }
    }
    
    // MARK: - Hash
    
    func sha256Hash(_ data: Data) -> Data {
        
        let hash = decoratee.sha256Hash(data)
        log(.debug, "Created hash (\(hash.count)) for data (\(data.count)): \"\(String(data: data, encoding: .utf8) ?? "n/a")\".", #file, #line)
        
        return hash
    }
}
