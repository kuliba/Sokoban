//
//  Crypto.swift
//  
//
//  Created by Igor Malyarov on 10.08.2023.
//

import CryptoKit
import Foundation

/// A namespace.
public enum Crypto {}

public extension Crypto {
    
    enum Error: Swift.Error {
        
        case signFailure(Swift.Error?)
        case creatingSignatureFailure(Swift.Error?)
        case verificationFailure(Swift.Error?)
        case encryptionFailure(Swift.Error?)
        case decryptionFailure(Swift.Error?)
        case dataCreationFromBase64StringFailure(String)
        case notFoundServerCertificateData
        case extractPublicKeyFromPrivateKeyFailure
        case unableExtractPublicKeyFromServerCertificate
        case unableDecodeDataFromBase64String
        case unableExtractCertFromDerData
        case unableCopyExternalRepresentation(String)
        case secKeyCreationWithDataFailure(bits: Int, keyType: CFString, keyClass: CFString, String)
        case keysGenerationFailure(bits: Int, keyType: CFString, Swift.Error)
        case keysPairGenerationFailure(keySize: Int, keyType: CFString, OSStatus)
        case keyExchangeResultFailure(Swift.Error)
        case base64StringEncodedData(String)
        case encryptionFailed(String? = nil)
        case decryptionFailed(String? = nil)
    }
}
