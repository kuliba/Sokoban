//
//  ChaChaPolyEncryptionAgent.swift
//  
//
//  Created by Max Gribov on 21.07.2023.
//

import Foundation
import CryptoKit

public final class ChaChaPolyEncryptionAgent {
    
    private let symmetricKey: SymmetricKey
    
    public init(with keyData: Data) {
        
        self.symmetricKey = SymmetricKey(data: keyData)
    }
    
    public func encrypt(_ data: Data) throws -> Data {
        
        try ChaChaPoly.seal(data, using: symmetricKey).combined
    }
    
    public func decrypt(_ data: Data) throws -> Data {
        
        let sealedBox = try ChaChaPoly.SealedBox(combined: data)

        return try ChaChaPoly.open(sealedBox, using: symmetricKey)
    }
}
