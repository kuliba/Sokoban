//
//  KeychainAgentSpy.swift
//  VortexTests
//
//  Created by Max Gribov on 26.07.2023.
//

import Foundation
@testable import Vortex

final class KeychainAgentSpy: KeychainAgentProtocol {
    
    private(set) var loadAttemptsTypes: [KeychainValueType] = []
    private(set) var storeAttemptsTypes: [KeychainValueType] = []
    private(set) var clearAttemptsTypes: [KeychainValueType] = []
    private(set) var isStorredAttemptsTypes: [[KeychainValueType]] = []
    private(set) var storedKeyData: Data?
    let keyValueType: KeychainValueType
    
    init(storedKeyData: Data?, keyValueType: KeychainValueType) {
     
        self.storedKeyData = storedKeyData
        self.keyValueType = keyValueType
    }
    
    func store<Value>(_ value: Value, type: Vortex.KeychainValueType) throws where Value : Decodable, Value : Encodable {
        
        storeAttemptsTypes.append(type)
        guard type == keyValueType, let keyValue = value as? Data else {
            throw anyNSError()
        }
        
        storedKeyData = keyValue
    }
    
    func load<Value>(type: Vortex.KeychainValueType) throws -> Value where Value : Decodable, Value : Encodable {
        
        loadAttemptsTypes.append(type)
        guard type == keyValueType, let storedKeyData else {
            throw anyNSError()
        }
        
        return storedKeyData as! Value
    }
    
    func clear(type: Vortex.KeychainValueType) throws {
        
        clearAttemptsTypes.append(type)
        guard keyValueType == type else {
            throw Error.clearTypeMissmatch
        }
        
        storedKeyData = nil
    }
    
    func isStoredString(values: [Vortex.KeychainValueType]) -> Bool {
        
        isStorredAttemptsTypes.append(values)
        guard values.count == 1, values.contains(keyValueType), storedKeyData != nil else {
            return false
        }
        
        return true
    }
    
    enum Error: Swift.Error {
        case clearTypeMissmatch
    }
}
