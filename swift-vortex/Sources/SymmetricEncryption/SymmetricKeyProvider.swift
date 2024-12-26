//
//  SymmetricKeyProvider.swift
//  
//
//  Created by Max Gribov on 21.07.2023.
//

import Foundation
import CryptoKit

public final class SymmetricKeyProvider: SymmetricKeyProviderProtocol {
    
    public let symmetricKey: SymmetricKey
    
    public init(keySize: SymmetricKeySize) {
        
        self.symmetricKey = .init(size: keySize)
    }
    
    public func getSymmetricKeyRawRepresentation() -> Data {
        
        symmetricKey.rawRepresentation
    }
}

public extension SymmetricKey {

    var rawRepresentation: Data {
        
        withUnsafeBytes { body in
            Data(body)
        }
    }
}
