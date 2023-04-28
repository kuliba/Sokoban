//
//  MockKeysProvider.swift
//  ForaBank
//
//  Created by Max Gribov on 07.02.2023.
//

import Foundation

struct MockKeysProvider: EncryptionKeysProvider {
    
    func generateKeysPair() throws -> EncryptionKeysPair {
        
        throw Error.unsupproted
    }
}

extension MockKeysProvider {
    
    enum Error: LocalizedError {
        
        case unsupproted
    }
}
