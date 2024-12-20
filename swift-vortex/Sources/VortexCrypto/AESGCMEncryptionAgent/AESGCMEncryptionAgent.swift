//
//  AESGCMEncryptionAgent.swift
//  
//
//  Created by Igor Malyarov on 24.08.2023.
//

import CryptoKit
import Foundation

public final class AESGCMEncryptionAgent {
    
    private let symmetricKey: SymmetricKey
    
    public init(symmetricKey: SymmetricKey) {
        
        self.symmetricKey = symmetricKey
    }
    
    public func encrypt(_ data: Data) throws -> Data {
        
        guard let encrypted = try AES.GCM.seal(data, using: symmetricKey).combined
        else {
            throw Error.encryptionFailed
        }
        
        return encrypted
    }
    
    public func decrypt(_ data: Data) throws -> Data {
        
        let sealedBox = try AES.GCM.SealedBox(combined: data)
        
        return try AES.GCM.open(sealedBox, using: symmetricKey)
    }
    
    public enum Error: Swift.Error {
        
        case encryptionFailed
    }
}

public extension AESGCMEncryptionAgent {
    
    convenience init(size: SymmetricKeySize) {
        
        self.init(symmetricKey: .init(size: size))
    }
    
    convenience init(bitCount: Int) {
        
        self.init(size: .init(bitCount: bitCount))
    }
    
    convenience init(data: ContiguousBytes) {
        
        self.init(symmetricKey: .init(data: data))
    }
}

