//
//  ValetKeychainAgent.swift
//  ForaBank
//
//  Created by Max Gribov on 14.02.2022.
//

import Foundation
import Valet

class ValetKeychainAgent: KeychainAgentProtocol {

    private let valet: Valet
    
    init() {
        
        //TODO: migrate to `ForaBank` name
        let identifier = Identifier(nonEmpty: "Druidia")!
        self.valet = Valet.valet(with: identifier, accessibility: .whenUnlockedThisDeviceOnly)
    }
    
    func value(for key: KeychainAgentKey) throws -> String {
        
        return try valet.string(forKey: key.rawValue)
    }
    
    func set(value: String, for key: KeychainAgentKey) throws {
        
        try valet.setString(value, forKey: key.rawValue)
    }
    
    func removeValue(for key: KeychainAgentKey) throws {
        
        try valet.removeObject(forKey: key.rawValue)
    }
}
