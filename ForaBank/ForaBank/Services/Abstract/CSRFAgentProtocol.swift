//
//  CSRFAgentProtocol.swift
//  ForaBank
//
//  Created by Max Gribov on 23.01.2022.
//

import Foundation

protocol CSRFAgentProtocol {
    
    associatedtype Agent: EncryptionAgent
    
    var publicKeyData: String { get }
    
    init(_ keysProvider: EncryptionKeysProvider, _ serverCertificatesData: String, _ serverPublicKeyEncrypted: String) throws
    func encrypt(_ stringData: String) throws -> String
    func decrypt(_ stringData: String) throws -> String
}
