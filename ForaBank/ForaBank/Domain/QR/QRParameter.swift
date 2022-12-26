//
//  QRParameter.swift
//  ForaBank
//
//  Created by Константин Савялов on 17.10.2022.
//

import Foundation

struct QRParameter: Codable, Equatable {
    
    let parameter: Kind
    let keys: [String]
    let type: ValueType
}

//MARK: - Types

extension QRParameter {
    
    enum Kind: Equatable {
        
        case general(General)
        case value(String)
        
        enum General: String, Codable {
            
            case inn = "GENERAL_INN"
            case amount = "GENERAL_AMOUNT"
            case account = "GENERAL_ACCOUNT"
            case bic = "GENERAL_BIC"
            case name = "GENERAL_NAME"
            case firstName = "GENERAL_FIRST_NAME"
            case lastName = "GENERAL_LAST_NAME"
            case middleName = "GENERAL_MIDDLE_NAME"
            case kpp = "GENERAL_KPP"
            case purpose = "GENERAL_PURPOSE"
            case techcode = "GENERAL_TECHCODE"
        }
        
        var name: String {
            
            switch self {
            case let .general(general): return general.rawValue
            case let .value(valueName): return valueName
            }
        }
    }
        
    enum ValueType: String, Codable {
        
        case string = "STRING"
        case integer = "INTEGER"
        case double = "DOUBLE"
        case date = "DATE"
    }
}

//MARK: - Helpers

extension QRParameter {
    
    var swiftType: Any.Type {
        
        switch type {
        case .double: return Double.self
        case .string: return String.self
        case .integer: return Int.self
        case .date: return Date.self
        }
    }
}

//MARK: - Codable

extension QRParameter.Kind: Codable {
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.singleValueContainer()
        
        do {
            
            let general = try container.decode(General.self)
            self = .general(general)
            
        } catch {
            
            let value = try container.decode(String.self)
            self = .value(value)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        
        var container = encoder.singleValueContainer()
        try container.encode(name)
    }
}

