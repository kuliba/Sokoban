//
//  Crypto+SecKey.swift
//  
//
//  Created by Igor Malyarov on 18.08.2023.
//

import Foundation

public extension Crypto {
    
    // MARK: - Sing & Verify
    
    static func sign(
        _ data: Data,
        withPrivateKey key: SecKey,
        algorithm: SecKeyAlgorithm = .rsaSignatureRaw
    ) throws -> Data {
        
        var error: Unmanaged<CFError>? = nil
        guard let signed = SecKeyCreateSignature(key, algorithm, data as CFData, &error) as? Data
        else {
            throw Error.signFailure(error?.takeRetainedValue() as? Swift.Error)
        }
        
        return signed
    }

    static func verify(
        _ data: Data,
        withPublicKey key: SecKey,
        signature: Data,
        algorithm: SecKeyAlgorithm = .rsaSignatureRaw
    ) throws -> Bool {
        
        var error: Unmanaged<CFError>? = nil
        let isVerified = SecKeyVerifySignature(key, algorithm, data as CFData, signature as CFData, &error)
        if let error {
            throw Error.verificationFailure(error.takeRetainedValue() as Swift.Error)
        }
        
        return isVerified
    }

    static func createSignature(
        for data: Data,
        usingPrivateKey key: SecKey,
        algorithm: SecKeyAlgorithm = .rsaSignatureRaw
    ) throws -> Data {
        
        var error: Unmanaged<CFError>? = nil
        guard let signature = SecKeyCreateSignature(key, algorithm, data as CFData, &error) as? Data
        else {
            throw Error.creatingSignatureFailure(error?.takeRetainedValue() as? Swift.Error)
        }
        
        return signature
    }

    // MARK: - SecKey
    
    static func decryptPublicKey(
        from string: String,
        with secKey: SecKey,
        decryptionAlgorithm: SecKeyAlgorithm = .rsaEncryptionRaw,
        keyType: CFString = kSecAttrKeyTypeEC,
        advancedBy amount: Int = 415
    ) throws -> SecKey {
        
        let decryptedData = try decrypt(string, with: decryptionAlgorithm, using: secKey)
        
        // MARK: - Advance!
        let amount = min(amount, decryptedData.count)
        let advanced = decryptedData.advanced(by: amount)
        
        let publicKey = try createSecKeyWith(
            data: advanced,
            keyType: keyType
        )
        
        return publicKey
    }
    
    /// Create `Public Key` from data
    static func createSecKeyWith(
        data: Data,
        keyType: CFString = kSecAttrKeyTypeRSA,
        keySizeInBits: Int = 512 * 8
    ) throws -> SecKey {
        
        let parameters: [String: Any] = [
            kSecAttrKeyType as String: keyType,
            kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
            kSecAttrKeySizeInBits as String: keySizeInBits,
            SecKeyKeyExchangeParameter.requestedSize.rawValue as String: 32
        ]
        
        var error: Unmanaged<CFError>? = nil
        guard let publicKey = SecKeyCreateWithData(data as CFData, parameters as CFDictionary, &error)
        else {
            throw Error.secKeyCreationWithDataFailure((error!.takeRetainedValue() as Swift.Error).localizedDescription)
        }
        
        return publicKey
    }
    
    static func createRandomSecKeys(
        keyType: CFString,
        keySizeInBits: Int
    ) throws -> (
        privateKey: SecKey,
        publicKey: SecKey
    ) {
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: keyType,
            kSecAttrKeySizeInBits as String: keySizeInBits,
            kSecPrivateKeyAttrs as String:
                [kSecAttrIsPermanent as String: false]
        ]
        
        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error),
              let publicKey = SecKeyCopyPublicKey(privateKey)
        else {
            throw Error.keysGenerationFailure(
                bits: keySizeInBits,
                keyType: keyType,
                error!.takeRetainedValue()
            )
        }
        
        return (privateKey, publicKey)
    }

    static func decrypt(
        _ string: String,
        with decryptionAlgorithm: SecKeyAlgorithm,
        using secKey: SecKey
    ) throws -> Data {
        
        guard let data = Data(base64Encoded: string, options: .ignoreUnknownCharacters)
        else {
            throw Error.dataCreationFromBase64StringFailure(string)
        }
        
        let decryptedData = try decrypt(data, using: decryptionAlgorithm, secKey: secKey)
        
        return decryptedData
    }
    
    static func decrypt(
        _ data: Data,
        using decryptionAlgorithm: SecKeyAlgorithm = .rsaEncryptionPKCS1,
        secKey: SecKey
    ) throws -> Data {
        
        var error: Unmanaged<CFError>? = nil
        guard let decrypted = SecKeyCreateDecryptedData(secKey, decryptionAlgorithm, data as CFData, &error) as Data?
        else {
            throw error!.takeRetainedValue()
        }
        
        return decrypted
    }
    
    /// Extracts key from certificate from the file at given URL.
    static func secKey(fromCertURL url: URL) throws -> SecKey {
        
        let contents = try String(contentsOf: url)
        return try serverCertPublicKey(contents)
    }
    
    // MARK: - From ForaBank
    
    /// Extracts first certificate public RSA key in `SecKey` format from certificates data string
    /// - Parameter certificatesData: certificates data encoded in base64 string
    /// - Returns: first certificate public RSA key
    
    static func serverCertPublicKey(_ certificatesData: String) throws -> SecKey {
        
        // Extract server certificates in PEM from string
        let certificatesPemData = pemCertificates(from: certificatesData)
        
        // Expected first server cert data
        guard let serverCertData = certificatesPemData.first else {
            throw Crypto.Error.notFoundServerCertificateData
        }
        
        // Convert server certificate from PEM into SecCertificate
        let serverCert = try certificate(from: serverCertData)
        
        // Extract key from server certificate
        guard let serverCertKey = SecCertificateCopyKey(serverCert) else {
            throw Crypto.Error.unableExtractPublicKeyFromServerCertificate
        }
        
        return serverCertKey
    }
    
    /// Parses certificates data string into array
    /// - Parameter data: certificates data encoded in base64 string
    /// - Returns: certificates data array in PEM format string
    
    static func pemCertificates(from data: String) -> [String] {
        
        var certs = [String]()
        
        let components = data.components(separatedBy: "\n")
        var currentCert = ""
        for item in components {
            
            if item == "-----BEGIN CERTIFICATE-----" {
                
                currentCert = ""
                currentCert += "-----BEGIN CERTIFICATE-----" + "\n"
                
            } else if item == "-----END CERTIFICATE-----" {
                
                currentCert += "-----END CERTIFICATE-----" + "\n"
                certs.append(currentCert)
                
            } else {
                
                currentCert += item + "\n"
            }
        }
        
        return certs
    }
    
    /// Creates `SecCertificate` from pem certificate string
    /// - Parameter pemData: certificate in PEM format string
    /// - Returns: SecCertificate
    
    static func certificate(from pemData: String) throws -> SecCertificate {
        
        let derString = pemData.replacingOccurrences(of: "-----BEGIN CERTIFICATE-----", with: "")
            .replacingOccurrences(of: "-----END CERTIFICATE-----", with: "")
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\r", with: "")
        
        guard let derData = Data(base64Encoded: derString, options: .ignoreUnknownCharacters) as CFData? else {
            throw Crypto.Error.unableDecodeDataFromBase64String
        }
        
        guard let cert = SecCertificateCreateWithData(nil, derData) else {
            throw Crypto.Error.unableExtractCertFromDerData
        }
        
        return cert
    }
}
