//
//  KeychainAgentProtocol.swift
//  ForaBank
//
//  Created by Max Gribov on 14.02.2022.
//

import Foundation

protocol KeychainAgentProtocol {
    
    func value(for key: KeychainAgentKey) throws -> String
    func set(value: String, for key: KeychainAgentKey) throws
    func removeValue(for key: KeychainAgentKey) throws
}

enum KeychainAgentKey: String {
    
    case pincode
}
