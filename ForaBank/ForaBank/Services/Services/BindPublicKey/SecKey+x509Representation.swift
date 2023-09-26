//
//  SecKey+x509Representation.swift
//  ForaBank
//
//  Created by Igor Malyarov on 26.09.2023.
//

import Foundation
import Security

#warning("move to ForaCrypto.Crypto")
extension SecKey {
    
    #warning("reuse ForaCrypto.Crypto.Error")
    enum KeyExtractionError: Error {
        case invalidKey
        case conversionFailure
    }
    
    func x509Representation() throws -> Data {
        
        // DER Encoding for ASN.1 sequence header for X.509 public key
        let sequenceHeader: [UInt8] = [0x30, 0x82]
        
        // DER Encoding for ASN.1 algorithm identifier for RSA encryption
        let algorithmIdentifier: [UInt8] = [
            0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00
        ]
        
        // Obtain the public key bits
        guard let publicKeyBits = SecKeyCopyExternalRepresentation(self, nil) as Data?
        else {
            throw KeyExtractionError.invalidKey
        }
        
        // Calculate total length
        let totalLength = algorithmIdentifier.count + 2 + publicKeyBits.count
        guard totalLength <= 0xFFFF
        else {
            throw KeyExtractionError.conversionFailure
        }
        
        // Create NSMutableData and append all the bytes
        let data = NSMutableData()
        data.append(sequenceHeader, length: 2)
        data.append([UInt8((totalLength & 0xFF00) >> 8), UInt8(totalLength & 0x00FF)], length: 2)
        data.append(algorithmIdentifier, length: algorithmIdentifier.count)
        data.append(publicKeyBits)
        
        return data as Data
    }
}
