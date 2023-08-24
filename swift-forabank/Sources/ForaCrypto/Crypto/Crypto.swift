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
        
        case dataCreationFromBase64StringFailure(String)
        case notFoundServerCertificateData
        case unableExtractPublicKeyFromServerCertificate
        case unableDecodeDataFromBase64String
        case unableExtractCertFromDerData
        case secKeyCreationWithDataFailure(String)
        case keysGenerationFailure(bits: Int, keyType: CFString, Swift.Error)
        case keyExchangeResultFailure(Swift.Error)
        case base64StringEncodedData(String)
    }
}
