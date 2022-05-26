//
//  SettingType.swift
//  ForaBank
//
//  Created by Max Gribov on 14.02.2022.
//

import Foundation

enum SettingType {
    
    case transfers(Transfers)
    case security(Security)
    case interface(Interface)
        
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
    }
}

extension SettingType {
    
    var identifier: String {
        
        switch self {
        case .transfers(let transfers):
            return "setting_transfers_\(transfers.rawValue)"
            
        case .security(let security):
            return "setting_security_\(security.rawValue)"
            
        case .interface(let interface):
            return "setting_interface_\(interface.rawValue)"
        }
    }
}
