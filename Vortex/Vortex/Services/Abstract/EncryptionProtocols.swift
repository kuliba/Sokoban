//
//  Encryption.swift
//  Vortex
//
//  Created by Max Gribov on 23.01.2022.
//

import Foundation
import Security

struct EncryptionKeysPair {
    
    let publicKey: SecKey
    let privateKey: SecKey
}

protocol EncryptionKeysProvider {
    
    func generateKeysPair() throws -> EncryptionKeysPair
}

protocol EncryptionAgent {
    
    //TODO: remove init
    init(with keyData: Data)
    func encrypt(_ data: Data) throws -> Data
    func decrypt(_ data: Data) throws -> Data
}
