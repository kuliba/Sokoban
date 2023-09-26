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
    
    /// Returns Public Key X.509 Representation.
    func x509Representation() throws -> Data {
        
        try publicKeyData().prependingX509Header()
    }
    
    /// Returns public key data representation.
    func publicKeyData() throws -> Data {
        
        guard let publicKeyData = SecKeyCopyExternalRepresentation(self, nil) as Data?
        else {
            throw KeyExtractionError.invalidKey
        }
        
        return publicKeyData
    }
}

extension Data {
    
    /// https://github.com/henrinormak/Heimdall
    func prependingX509Header() -> Data {
        
        let result = NSMutableData()
        
        let encodingLength: Int = (self.count + 1).encodedOctets().count
        let OID: [CUnsignedChar] = [
            0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
            0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00]
        
        var builder: [CUnsignedChar] = []
        
        // ASN.1 SEQUENCE
        builder.append(0x30)
        
        // Overall size, made of OID + bitstring encoding + actual key
        let size = OID.count + 2 + encodingLength + self.count
        let encodedSize = size.encodedOctets()
        builder.append(contentsOf: encodedSize)
        result.append(builder, length: builder.count)
        result.append(OID, length: OID.count)
        builder.removeAll(keepingCapacity: false)
        
        builder.append(0x03)
        builder.append(contentsOf: (self.count + 1).encodedOctets())
        builder.append(0x00)
        result.append(builder, length: builder.count)
        
        // Actual key bytes
        result.append(self)
        
        return result as Data
    }
}

extension NSInteger {
    
    func encodedOctets() -> [CUnsignedChar] {
        // Short form
        if self < 128 {
            return [CUnsignedChar(self)];
        }
        
        // Long form
        let i = Int(log2(Double(self)) / 8 + 1)
        var len = self
        var result: [CUnsignedChar] = [CUnsignedChar(i + 0x80)]
        
        for _ in 0..<i {
            result.insert(CUnsignedChar(len & 0xFF), at: 1)
            len = len >> 8
        }
        
        return result
    }
}
