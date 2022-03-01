//
//  KeychainAgentMock.swift
//  ForaBank
//
//  Created by Max Gribov on 01.03.2022.
//

import Foundation

class KeychainAgentMock: KeychainAgentProtocol {
    
    private var storage = [String: Data]()
    
    func store<Value>(_ value: Value, type: KeychainValueType) throws where Value : Decodable, Value : Encodable {
        
        storage[type.rawValue] = try JSONEncoder().encode(value)
    }
    
    func load<Value>(type: KeychainValueType) throws -> Value where Value : Decodable, Value : Encodable {
        
        guard let data = storage[type.rawValue] else {
            throw KeychainAgentError.unableLoadValueType(type)
        }
        
        return try JSONDecoder().decode(Value.self, from: data)
    }
    
    func clear(type: KeychainValueType) throws {
        
        storage[type.rawValue] = nil
    }  
}
