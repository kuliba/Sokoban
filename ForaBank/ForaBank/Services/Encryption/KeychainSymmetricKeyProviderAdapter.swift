//
//  KeychainSymmetricKeyProviderAdapter.swift
//  Vortex
//
//  Created by Max Gribov on 21.07.2023.
//

import Foundation
import SymmetricEncryption

final class KeychainSymmetricKeyProviderAdapter<KeychainAgent, KeyProvider>: SymmetricKeyProviderProtocol where KeychainAgent: KeychainAgentProtocol, KeyProvider: SymmetricKeyProviderProtocol {

    private let keychainAgent: KeychainAgent
    private let keyProvider: KeyProvider
    private let keychainValueType: KeychainValueType
    
    init(keychainAgent: KeychainAgent, keyProvider: KeyProvider, keychainValueType: KeychainValueType) {
        
        self.keychainAgent = keychainAgent
        self.keyProvider = keyProvider
        self.keychainValueType = keychainValueType
    }
    
    func getSymmetricKeyRawRepresentation() -> Data {
        
        do {
            return try keychainAgent.load(type: keychainValueType)
            
        } catch {
            
            let symmetricKeyData = keyProvider.getSymmetricKeyRawRepresentation()
            //TODO: log or handle error
            try? keychainAgent.store(symmetricKeyData, type: keychainValueType)
            
            return symmetricKeyData
        }
    }
}
