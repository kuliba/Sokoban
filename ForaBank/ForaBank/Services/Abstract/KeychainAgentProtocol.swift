//
//  KeychainAgentProtocol.swift
//  ForaBank
//
//  Created by Max Gribov on 14.02.2022.
//

import Foundation
import UIKit

protocol KeychainAgentProtocol {
    
    func store<Value>(_ value: Value, type: KeychainValueType) throws where Value : Codable
    func load<Value>(type: KeychainValueType) throws -> Value where Value : Codable
    func clear(type: KeychainValueType) throws
    func isStoredString(values: [KeychainValueType]) -> Bool
}

enum KeychainAgentError: Error {
    
    case unableLoadValueType(KeychainValueType)
}
