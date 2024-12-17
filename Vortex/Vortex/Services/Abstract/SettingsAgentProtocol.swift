//
//  SettingsAgentProtocol.swift
//  ForaBank
//
//  Created by Max Gribov on 14.02.2022.
//

import Foundation

protocol SettingsAgentProtocol {
    
    func store<Setting>(_ setting: Setting, type: SettingType) throws where Setting : Codable
    func load<Setting>(type: SettingType) throws -> Setting where Setting : Codable
    func clear(type: SettingType)
}

enum SettingsAgentError: LocalizedError {
    
    case unableLoadDataType(SettingType)
    
    var errorDescription: String? {
        
        switch self {
        case .unableLoadDataType(let settingType):
            return "Unable to load setting data of type: \(settingType)"
        }
    }
}

