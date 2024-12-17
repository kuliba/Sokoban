//
//  MockEncryptionAgent.swift
//  ForaBank
//
//  Created by Max Gribov on 07.02.2023.
//

import Foundation

struct MockEncryptionAgent: EncryptionAgent {
    
    init(with keyData: Data) {}
    
    func encrypt(_ data: Data) throws -> Data { data }
    
    func decrypt(_ data: Data) throws -> Data { data }
}
