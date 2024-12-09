//
//  LocalAgentOldSymmetricKeyCleaner.swift
//  Vortex
//
//  Created by Max Gribov on 26.07.2023.
//

import Foundation

final class LocalAgentOldSymmetricKeyCleaner<S, K> where S: SettingsAgentProtocol, K: KeychainAgentProtocol {
    
    private let settingsAgent: S
    private let keychainAgent: K
    
    init(settingsAgent: S, keychainAgent: K) {
        
        self.settingsAgent = settingsAgent
        self.keychainAgent = keychainAgent
    }
    
    func clean() throws {
        
        if !isAppLaunchedBefore, keychainAgent.isStoredString(values: [.symmetricKeyCache]) {
            
            try keychainAgent.clear(type: .symmetricKeyCache)
        }
    }
    
    private var isAppLaunchedBefore: Bool {
        
        do {
            
            let launchedBefore: Bool = try settingsAgent.load(type: .general(.launchedBefore))
            return launchedBefore
            
        } catch {
            
            return false
        }
    }
}
