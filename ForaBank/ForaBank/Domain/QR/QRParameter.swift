//
//  QRParameter.swift
//  ForaBank
//
//  Created by Константин Савялов on 17.10.2022.
//

import Foundation

struct QRParameter: Codable {
    
    let parameter: Kind
    let keys: [String]
    let type: ValueType
    
    enum Kind: String, Codable {
        
        case inn = "GENERAL_INN"
        case amount =  "GENERAL_AMOUNT"
        case account = "GENERAL_ACCOUNT"
        case bic = "GENERAL_BIC"
        case name = "GENERAL_NAME"
        case firstName = "GENERAL_FIRST_NAME"
        case lastName = "GENERAL_LAST_NAME"
        case middleName = "GENERAL_MIDDLE_NAME"
        case kpp = "GENERAL_KPP"
        case purpose = "GENERAL_PURPOSE"
//        case value(String)
        
//        var name: String {
//
//            switch self {
//            case .inn:        return "GENERAL_INN"
//            case .amount:     return "GENERAL_AMOUNT"
//            case .account:    return "GENERAL_ACCOUNT"
//            case .bic:        return "GENERAL_BIC"
//            case .name:       return "GENERAL_NAME"
//            case .firstName:  return "GENERAL_FIRST_NAME"
//            case .lastName:   return "GENERAL_LAST_NAME"
//            case .middleName: return "GENERAL_MIDDLE_NAME"
//            case .kpp:        return "GENERAL_KPP"
//            case .purpose:    return "GENERAL_PURPOSE"
//            case let .value(valueName): return valueName
//
//            }
//        }
    }
    
    var swiftType: Any.Type {
        
        switch type {
        case .double:  return Double.self
        case .string:  return String.self
        case .integer: return Int.self
        }
    }
    
    enum ValueType: String, Codable {
        
        case string = "STRING"
        case integer = "INTEGER"
        case double = "DOUBLE"
    }
}
