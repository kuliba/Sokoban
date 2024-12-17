//
//  SettingsAgentMock.swift
//  ForaBank
//
//  Created by Max Gribov on 01.03.2022.
//

import Foundation

class SettingsAgentMock: SettingsAgentProtocol {
    
    private var storage = [String : Data]()
    
    func store<Setting>(_ setting: Setting, type: SettingType) throws where Setting : Decodable, Setting : Encodable {
        
        storage[type.identifier] = try JSONEncoder().encode(setting)
    }
    
    func load<Setting>(type: SettingType) throws -> Setting where Setting : Decodable, Setting : Encodable {
        
        guard let data = storage[type.identifier] else {
            throw SettingsAgentError.unableLoadDataType(type)
        }
        
        return try JSONDecoder().decode(Setting.self, from: data)
    }
    
    func clear(type: SettingType) {
        
        storage[type.identifier] = nil
    }
}
