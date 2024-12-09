//
//  Payments+Service.swift
//  Vortex
//
//  Created by Max Gribov on 20.02.2022.
//

import Foundation
import UIKit

extension Payments.Service {
    
    var operators: [Payments.Operator] {
        
        switch self {
        case .fns:              return [.fns, .fnsUin]
        case .fms:              return [.fms]
        case .fssp:             return [.fssp]
        case .sfp:              return [.sfp]
        case .abroad:           return [.direct]
        case .requisites:       return [.requisites]
        case .c2b:              return [.c2b]
        case .toAnotherCard:    return [.toAnotherCard]
        case .mobileConnection: return [.mobileConnection]
        case .return:           return [.return]
        case .change:           return [.change]
        case .internetTV:       return [.internetTV]
        case .utility:          return [.utility]
        case .transport:        return [.transport]
        case .avtodor:          return [.avtodor]
        case .gibdd:            return [.gibdd]
        }
    }
    
    var id: String { "service_\(rawValue)"}
    
    var name: String {
        
        switch self {
        case .fns:  return "ФНС"
        case .fms:  return "ФМС"
        case .fssp: return "ФССП"
        case .sfp:  return "Перевод по номеру телефона"
        default:    return "UNKNOWN"
        }
    }
    
    var transferType: Payments.Operation.TransferType {
        
        switch self {
        case .fms, .fns, .fssp : return .anyway
        case .sfp:               return .sfp
        case .abroad:            return .abroad
        case .requisites:        return .requisites
        case .c2b:               return .c2b
        case .toAnotherCard:     return .toAnotherCard
        case .mobileConnection:  return .mobileConnection
        case .return:            return .return
        case .change:            return .change
        case .internetTV:        return .internetTV
        case .utility:           return .utility
        case .transport:         return .transport
        case .avtodor:           return .avtodor
        case .gibdd:             return .gibdd
        }
    }
}
