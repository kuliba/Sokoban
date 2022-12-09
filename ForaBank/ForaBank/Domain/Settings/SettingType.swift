//
//  SettingType.swift
//  ForaBank
//
//  Created by Max Gribov on 14.02.2022.
//

import Foundation

enum SettingType {
    
    case general(General)
    case transfers(Transfers)
    case security(Security)
    case interface(Interface)
        
    enum General: String {
        
        case launchedBefore
    }
    
    enum Transfers: String {
        
        case sfp
    }
    
    enum Security: String {
        
        case sensor
        case push
        case block
    }
    
    enum Interface: String {
        
        case mainSections
        case inactiveProducts
        case tempates
        case productsHidden
        case productsSections
        case productsMoney
        case myProductsOnboarding
    }
}

extension SettingType {
    
    var identifier: String {
        
        switch self {
        case let .general(general):
            return "setting_general_\(general.rawValue)"
            
        case let .transfers(transfers):
            return "setting_transfers_\(transfers.rawValue)"
            
        case let .security(security):
            return "setting_security_\(security.rawValue)"
            
        case let .interface(interface):
            return "setting_interface_\(interface.rawValue)"
        }
    }
}

extension SettingType: CustomDebugStringConvertible {
    
    var debugDescription: String {
        
        switch self {
        case .general(let value): return "general : \(value.rawValue)"
        case .transfers(let value): return "transfers : \(value.rawValue)"
        case .security(let value): return "security : \(value.rawValue)"
        case .interface(let value): return "interface : \(value.rawValue)"
        }
    }
}
