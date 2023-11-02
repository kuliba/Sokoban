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
    
    // MARK: - Transport & Processing Key Domain

    func transportEncryptWithPadding(data: Data) throws -> Data {
        
        do {
            let encrypted = try decoratee.transportEncryptWithPadding(data: data)
            log("Encrypt with padding using transport public key success (\(encrypted.count)).")
            
            return encrypted
        } catch {
            log("Encrypt with padding using transport public key failure: \(error).")
            throw error
        }
    }
    
    func transportEncryptNoPadding(data: Data) throws -> Data {
        
        do {
            let encrypted = try decoratee.transportEncryptNoPadding(data: data)
            log("Encrypt without padding using transport public key success (\(encrypted.count)).")
            
            return encrypted
        } catch {
            log("Encrypt without padding using transport public key failure: \(error).")
            throw error
        }
    }
    
    func processingEncryptWithPadding(data: Data) throws -> Data {
        
        do {
            let encrypted = try decoratee.processingEncryptWithPadding(data: data)
            log("Encrypt using processing public key success (\(encrypted.count)).")
            
            return encrypted
        } catch {
            log("Encrypt using processing public key failure: \(error).")
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
            log("Shared Secret extraction success (\(sharedSecret.count)).")
            
            return sharedSecret
        } catch {
            log("Shared Secret extraction failure: \(error).")
            throw error
        }
    }
    
    func publicKeyData(
        forPublicKey publicKey: ECDHPublicKey
    ) throws -> Data {
        
        do {
            let keyData = try decoratee.publicKeyData(forPublicKey: publicKey)
            log("PublicKey data representation created (\(keyData.count)).")
            
            return keyData
        } catch {
            log("PublicKey data representation creation failure \(error).")
            throw error
        }
    }
    
    // MARK: - RSA Domain
    
    func generateRSA4096BitKeyPair() throws -> RSAKeyPair {
        
        do {
            let rsaKeyPair = try decoratee.generateRSA4096BitKeyPair()
            log("RSA Key Pair generation success \(rsaKeyPair).")
            
            return rsaKeyPair
        } catch {
            log("RSA Key Pair generation failure: \(error).")
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
            log("hashSignVerify success for data: \"\(String(data: data, encoding: .utf8) ?? "n/a")\".")
            
            return data
        } catch {
            log("hashSignVerify failure: \(error) for \"\(string)\".")
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
    
    func signNoHash(
        _ data: Data,
        withPrivateKey privateKey: RSAPrivateKey
    ) throws -> Data {
        
        do {
            let signed = try decoratee.signNoHash(
                data,
                withPrivateKey: privateKey
            )
            log("Signing success (\(signed)) for provided data: \"\(String(data: data, encoding: .utf8) ?? "n/a")\".")
            
            return signed
        } catch {
            log("Signing failure: \(error) for data \"\(String(data: data, encoding: .utf8) ?? "n/a")\".")
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
            log("AES encrypted (\(encrypted.count)) provided data: \"\(String(data: data, encoding: .utf8) ?? "n/a")\".")
            
            return encrypted
        } catch {
            log("AES Encryption Failure: \(error).")
            throw error
        }
    }
    
    // MARK: - Hash
    
    func sha256Hash(_ data: Data) -> Data {
        
        let hash = decoratee.sha256Hash(data)
        log("Created hash (\(hash.count)) for data (\(data.count)): \"\(String(data: data, encoding: .utf8) ?? "n/a")\".")
        
        return hash
    }
}
