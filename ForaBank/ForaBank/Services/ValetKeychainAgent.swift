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
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    
    init(valetName: String, encoder: JSONEncoder = .init(), decoder: JSONDecoder = .init()) {
        
        let identifier = Identifier(nonEmpty: valetName)!
        self.valet = Valet.valet(with: identifier, accessibility: .whenUnlockedThisDeviceOnly)
        self.encoder = encoder
        self.decoder = decoder
    }
    
    func store<Value>(_ value: Value, type: KeychainValueType) throws where Value : Decodable, Value : Encodable {
        
        let encoded = try encoder.encode(value)
        try valet.setObject(encoded, forKey: type.rawValue)
    }
    
    func load<Value>(type: KeychainValueType) throws -> Value? where Value : Decodable, Value : Encodable {
        
        let data = try valet.object(forKey: type.rawValue)
        
        return try decoder.decode(Value.self, from: data)
    }
    
    func clear(type: KeychainValueType) throws {
        
        try valet.removeObject(forKey: type.rawValue)
    }
}
