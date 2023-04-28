//
//  MockCSRFAgent.swift
//  ForaBank
//
//  Created by Max Gribov on 07.02.2023.
//

import Foundation

struct MockCSRFAgent<Agent: EncryptionAgent>: CSRFAgentProtocol {
    
    let publicKeyData: String
    
    init(_ keysProvider: EncryptionKeysProvider, _ serverCertificatesData: String, _ serverPublicKeyEncrypted: String) throws {
        
        self.publicKeyData = ""
    }
    
    func encrypt(_ stringData: String) throws -> String { stringData }
    
    func decrypt(_ stringData: String) throws -> String { stringData }
}
