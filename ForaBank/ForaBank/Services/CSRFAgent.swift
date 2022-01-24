//
//  CSRFAgent.swift
//  ForaBank
//
//  Created by Max Gribov on 23.01.2022.
//

import Foundation
import Security

struct CSRFAgent: CSRFAgentProtocol {
    
    let keysProvider: EncryptionKeysProvider
    
    //TODO: tests required
    func createSharedSecret(with serverCertificatesData: String, serverPublicKeyEncrypted: String) throws -> Data {
        
        // Extract server certificates in PEM from string
        let certificatesPemData = pemCertificates(from: serverCertificatesData)
        
        // Expected two certificates
        guard certificatesPemData.count == 2 else {
            throw CSRFAgentError.unexpectedServerCertificatesAmount
        }
        
        // Convert server certificate from PEM into SecCertificate
        let serverCert = try certificate(from: certificatesPemData[0])
        
        // Extract key from server certificate
        guard let serverCertKey = SecCertificateCopyKey(serverCert) else {
            throw CSRFAgentError.unexpectedServerCertificatesAmount
        }
        
        // Decode server public key from base 64
        guard let serverPublicKeyEncryptedData = Data(base64Encoded: serverPublicKeyEncrypted, options: .ignoreUnknownCharacters) else {
            throw CSRFAgentError.unableDecodeServerPublicKeyDataFromBase64String
        }
        
        // Decrypt server public key with key from certificate
        var error: Unmanaged<CFError>? = nil
        guard let serverPublicKeyData = SecKeyCreateDecryptedData(serverCertKey, .rsaEncryptionRaw,  serverPublicKeyEncryptedData as CFData, &error) as Data? else {
            throw CSRFAgentError.unableDecryptServerPublicKeyData(error?.takeRetainedValue())
        }
        
        // Prepare keys pair for shared secret
        let ourPrivateKey = try keysProvider.getPrivateKey()
        let serverPublicKey = try keysProvider.publicKey(from: serverPublicKeyData)
        
        return try sharedSecretData(with: ourPrivateKey, serverPublicKey: serverPublicKey)
    }
}

//MARK: internal helpers

internal extension CSRFAgent {
    
    func pemCertificates(from data: String) -> [String] {
        
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
    
    func certificate(from pemData: String) throws -> SecCertificate {
        
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
    
    func pemKey(from key: SecKey) throws -> String {
        
        var error: Unmanaged<CFError>? = nil
        guard let keyData = SecKeyCopyExternalRepresentation(key, &error) as Data? else {
            throw CSRFAgentError.errorWhileExtractingDataFromKey(error?.takeRetainedValue())
        }
        
        //TODO: add X.509 header if required
        //see: https://github.com/henrinormak/Heimdall/blob/59067b72f0d279a0cfa0d6699a082b2216437ab4/Heimdall/Heimdall.swift#L909
        
        return "-----BEGIN PUBLIC KEY-----" + keyData.base64EncodedString() + "-----END PUBLIC KEY-----"
    }
    
    //TODO: tests required
    func sharedSecretData(with ourPrivateKey: SecKey, serverPublicKey: SecKey) throws -> Data {
        
        let algorithm = SecKeyAlgorithm.ecdhKeyExchangeStandard
        let params = [kSecAttrKeySizeInBits as String: 384,
                       SecKeyKeyExchangeParameter.requestedSize.rawValue as String: 32,
                       kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
                       kSecPrivateKeyAttrs as String: [kSecAttrIsPermanent as String: false],
                       kSecPublicKeyAttrs as String:[kSecAttrIsPermanent as String: false]] as CFDictionary
        
        var error: Unmanaged<CFError>? = nil
        guard let sharedSecret = SecKeyCopyKeyExchangeResult(ourPrivateKey, algorithm, serverPublicKey, params, &error) as Data? else {
            throw CSRFAgentError.unableCreateSharedSecret(error?.takeRetainedValue())
        }
        
        return sharedSecret
    }
}

enum CSRFAgentError: Error {
    
    case unableDecodeDataFromBase64String
    case unableExtractCertFromDerData
    case errorWhileExtractingDataFromKey(CFError?)
    case unexpectedServerCertificatesAmount
    case unableExtractPublicServerKey
    case unableExtractPrivateServerKey
    case unableDecodeServerPublicKeyDataFromBase64String
    case unableDecryptServerPublicKeyData(CFError?)
    case unableCreateSharedSecret(CFError?)
}
