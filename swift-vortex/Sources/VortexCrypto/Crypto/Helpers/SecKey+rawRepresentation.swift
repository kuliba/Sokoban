//
//  SecKey+rawRepresentation.swift
//  
//
//  Created by Igor Malyarov on 07.09.2023.
//

import Foundation

public extension SecKey {
    
    /// The method returns data in the PKCS #1 format for an RSA key. For an elliptic curve public key, the format follows the ANSI X9.63 standard using a byte string of 04 || X || Y. For an elliptic curve private key, the output is formatted as the public key concatenated with the big endian encoding of the secret scalar, or 04 || X || Y || K. All of these representations use constant size integers, including leading zeros as needed.
    func rawRepresentation() throws -> Data {
        
        var error: Unmanaged<CFError>?
        guard let rawRepresentation = SecKeyCopyExternalRepresentation(self, &error) as? Data
        else {
            throw Crypto.Error.unableCopyExternalRepresentation((error!.takeRetainedValue() as Error).localizedDescription)
        }
        
        return rawRepresentation
    }
}
