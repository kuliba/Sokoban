//
//  Services+publicRSAKeySwaddler.swift
//  Vortex
//
//  Created by Igor Malyarov on 07.08.2023.
//

import CryptoKit
import CvvPin
import ForaCrypto
import Foundation
import TransferPublicKey

extension SecKey {
    
    public var rawRepresentation: Data {
        
        get throws {
            
            var error: Unmanaged<CFError>?
            guard let externalRepresentation = SecKeyCopyExternalRepresentation(self, &error) as? Data
            else {
                throw error!.takeRetainedValue() as Swift.Error
            }
            
            return externalRepresentation
        }
    }
}

func unimplemented<T>(
    _ message: String = "",
    file: StaticString = #file,
    line: UInt = #line
) -> T {
    
    fatalError("Unimplemented: \(message)", file: file, line: line)
}
