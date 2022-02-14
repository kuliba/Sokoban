//
//  KeychainAgentProtocol.swift
//  ForaBank
//
//  Created by Max Gribov on 14.02.2022.
//

import Foundation

protocol KeychainAgentProtocol {
    
    func store<Value>(_ value: Value, type: KeychainValueType) throws where Value : Codable
    func load<Value>(type: KeychainValueType) throws -> Value? where Value : Codable
    func clear(type: KeychainValueType) throws
}
