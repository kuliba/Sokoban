//
//  CSRFAgent.swift
//  ForaBank
//
//  Created by Max Gribov on 23.01.2022.
//

import Foundation
import Security

/// The agent involved in encrypting data sent to the server
struct CSRFAgent<Agent: EncryptionAgent>: CSRFAgentProtocol {
    
    /// our public key data encrypted with server public RSA key
    let publicKeyData: String
    
    /// The agent responsible for encryption
    private let encryptionAgent: Agent
    
    /// Initializes `CSRFAgent` with keys provider, server certificates data and encrypted server's public key
    /// - Parameters:
    ///   - keysProvider: our keys provider
    ///   - serverCertificatesData: server certificates data
    ///   - serverPublicKeyEncrypted: encrypted server's public key

    init(_ keysProvider: EncryptionKeysProvider, _ serverCertificatesData: String, _ serverPublicKeyEncrypted: String) throws {
        
        // generate keys pair
        let keys = try keysProvider.generateKeysPair()
        
        // extract key from server cert
        let serverCertPublicKey = try Self.serverCertPublicKey(serverCertificatesData)
        
        // decrypt server public key with server cert key
        let serverPublicKey = try Self.serverPublicKey(serverCertPublicKey, serverPublicKeyEncrypted)
        
        // create shared secret with our private key and server public key
        let sharedSecretData = try Self.sharedSecretData(keys.privateKey, serverPublicKey)
        
        // prepare encryption agent with shared secret
        self.encryptionAgent = Agent(with: sharedSecretData)
        
        // prepare external representation our public key encrypted with server cert key
        self.publicKeyData = try Self.externalPublicKeyDataStringEnrypted(publicKey: keys.publicKey, key: serverCertPublicKey)
    }
    
    /// Encrypts string data with shared key
    /// - Parameter stringData: string data to encrypt
    /// - Returns: encrypted string data encoded in base64
    
    func encrypt(_ stringData: String) throws -> String {
        
        let data = Data(stringData.utf8)
        let encrypted = try encryptionAgent.encrypt(data)
        
        return encrypted.base64EncodedString()
    }
    
    /// Decrypts base64 string data with shared secret
    /// - Parameter stringData: string data to decrypt
    /// - Returns: decrypted string data encoded in base64
    
    func decrypt(_ stringData: String) throws -> String {
        
        guard let data = Data(base64Encoded: stringData) else {
            throw CSRFAgentError.faledConvertBase64StringToData
        }
        
        let decrypted = try encryptionAgent.decrypt(data)
        
        guard let decryptedString = String(data: decrypted, encoding: .utf8) else {
            throw CSRFAgentError.failedConvertDataToBase64String
        }
        
        return decryptedString
    }
}

//MARK: internal static helpers

internal extension CSRFAgent {
    
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
            throw CSRFAgentError.unableDecodeDataFromBase64String
        }
        
        guard let cert = SecCertificateCreateWithData(nil, derData) else {
            throw CSRFAgentError.unableExtractCertFromDerData
        }
        
        return cert
    }
    
    /// Extracts first certificate public RSA key in `SecKey` format from certificates data string
    /// - Parameter certificatesData: certificates data encoded in base64 string
    /// - Returns: first certificate public RSA key
   
    static func serverCertPublicKey(_ certificatesData: String) throws -> SecKey {
        
        // Extract server certificates in PEM from string
        let certificatesPemData = Self.pemCertificates(from: certificatesData)
        
        // Expected first server cert data
        guard let serverCertData = certificatesPemData.first else {
            throw CSRFAgentError.notFoundServerCertificateData
        }
        
        // Convert server certificate from PEM into SecCertificate
        let serverCert = try Self.certificate(from: serverCertData)
        
        // Extract key from server certificate
        guard let serverCertKey = SecCertificateCopyKey(serverCert) else {
            throw CSRFAgentError.unableExtractPublicKeyFromServerCertificate
        }
        
        return serverCertKey
    }
    
    /// Decrypts encrypted public key from server with certificate public RSA key
    /// - Parameters:
    ///   - serverCertKey: public RSA key from server certificate
    ///   - serverPublicKeyEncryptedString: encrypted public server key in base64 string
    /// - Returns: public server key
    
    static func serverPublicKey(_ serverCertKey: SecKey, _ serverPublicKeyEncryptedString: String) throws -> SecKey {
        
        guard let serverPublicKeyEncryptedData = Data(base64Encoded: serverPublicKeyEncryptedString, options: .ignoreUnknownCharacters) else {
            throw CSRFAgentError.unableDecodeServerPublicKeyDataFromBase64String
        }
        
        var error: Unmanaged<CFError>? = nil
        guard let serverPublicKeyDecryptedData = SecKeyCreateDecryptedData(serverCertKey, .rsaEncryptionRaw,  serverPublicKeyEncryptedData as CFData, &error) as Data? else {
            throw CSRFAgentError.unableDecryptServerPublicKeyData(error?.takeRetainedValue())
        }
        
        let withoutDERHeader = serverPublicKeyDecryptedData.advanced(by: 159) as CFData
        
        let parameters = [kSecAttrKeyType as String: kSecAttrKeyTypeEC,
                          kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
                          kSecAttrKeySizeInBits as String : 384,
                          SecKeyKeyExchangeParameter.requestedSize.rawValue as String: 32] as CFDictionary
        
        guard let serverPublicKey = SecKeyCreateWithData(withoutDERHeader, parameters, &error) else {
            throw CSRFAgentError.serverPublicKeyFromDataFailed(error?.takeRetainedValue())
        }
        
        return serverPublicKey
    }
    
    /// Prepares our public key data encrypted with server public RSA key
    /// - Parameters:
    ///   - publicKey: our public key
    ///   - key: server public RSA key
    /// - Returns: public key data encrypted encoded in base64 string
    
    static func externalPublicKeyDataStringEnrypted(publicKey: SecKey, key: SecKey) throws -> String {

        let publicKeyDataExternal = try Self.externalKeyData(from: publicKey)
        
        var error: Unmanaged<CFError>? = nil
        guard let publicKeyDataExternalEncrypted = SecKeyCreateEncryptedData(key, .rsaEncryptionPKCS1, publicKeyDataExternal as CFData, &error) as Data? else {

            throw CSRFAgentError.failedPublicKeyEncryption(error?.takeRetainedValue())
        }
        
        return publicKeyDataExternalEncrypted.base64EncodedString()
    }
    
    /// Converts `SecKey` to `Data`
    /// - Parameter key: `SecKey` required to convert
    /// - Returns: Binary data
    
    static func externalKeyData(from key: SecKey) throws -> Data {
    
        var error: Unmanaged<CFError>? = nil
        guard let keyData = SecKeyCopyExternalRepresentation(key, &error) as Data? else {
            throw CSRFAgentError.errorWhileExtractingDataFromKey(error?.takeRetainedValue())
        }
        
        let header: [UInt8] = [0x30, 0x76, 0x30, 0x10, 0x06, 0x07, 0x2A, 0x86, 0x48, 0xCE, 0x3D, 0x02, 0x01, 0x06, 0x05, 0x2B, 0x81, 0x04, 0x00, 0x22, 0x03, 0x62, 0x00] //384 bit EC keys
        
        var result = Data(header)
        result.append(keyData)

        return result
    }
    
    /// Creates shared secret key data based on our private key and server's public key
    /// - Parameters:
    ///   - ourPrivateKey: our private key
    ///   - serverPublicKey: server's public key
    /// - Returns: shared secret key data
   
    static func sharedSecretData(_ ourPrivateKey: SecKey, _ serverPublicKey: SecKey) throws -> Data {
        
        let algorithm = SecKeyAlgorithm.ecdhKeyExchangeStandard
        let params = [SecKeyKeyExchangeParameter.requestedSize.rawValue as String: 32] as CFDictionary

        var error: Unmanaged<CFError>? = nil
        guard let sharedSecret = SecKeyCopyKeyExchangeResult(ourPrivateKey, algorithm, serverPublicKey, params, &error) as Data? else {
            throw CSRFAgentError.unableCreateSharedSecret(error?.takeRetainedValue())
        }
        
        return sharedSecret.dropLast(16)
    }
}

//MARK: - Error

enum CSRFAgentError: Error {
    
    case serverPublicKeyFromDataFailed(Error?)
    case faledConvertBase64StringToData
    case failedConvertDataToBase64String
    case failedPublicKeyEncryption(Error?)
    case unableDecodeDataFromBase64String
    case unableExtractCertFromDerData
    case errorWhileExtractingDataFromKey(CFError?)
    case notFoundServerCertificateData
    case unableExtractPublicKeyFromServerCertificate
    case unableDecodeServerPublicKeyDataFromBase64String
    case unableDecryptServerPublicKeyData(CFError?)
    case unableCreateSharedSecret(CFError?)
}
