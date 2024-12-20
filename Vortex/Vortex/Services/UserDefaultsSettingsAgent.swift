//
//  UserDefaultsSettingsAgent.swift
//  Vortex
//
//  Created by Max Gribov on 14.02.2022.
//

import Foundation

class UserDefaultsSettingsAgent: SettingsAgentProtocol {

    private let defaults: UserDefaults
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    
    init(defaults: UserDefaults = .standard, encoder: JSONEncoder = .init(), decoder: JSONDecoder = .init()) {
        
        self.defaults = defaults
        self.encoder = encoder
        self.decoder = decoder
    }
    
    func store<Setting>(_ setting: Setting, type: SettingType) throws where Setting : Decodable, Setting : Encodable {
        
        let encoded = try encoder.encode(setting)
        defaults.set(encoded, forKey: type.identifier)
        defaults.synchronize()
    }
    
    func load<Setting>(type: SettingType) throws -> Setting where Setting : Decodable, Setting : Encodable {
        
        guard let data = defaults.data(forKey: type.identifier) else {
            throw SettingsAgentError.unableLoadDataType(type)
        }
        
        return try decoder.decode(Setting.self, from: data)
    }
    
    func clear(type: SettingType) {
        
        defaults.removeObject(forKey: type.identifier)
    }
}
