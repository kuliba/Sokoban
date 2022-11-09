//
//  Payments+Service.swift
//  ForaBank
//
//  Created by Max Gribov on 20.02.2022.
//

import Foundation
import UIKit

extension Payments.Service {
    
    var operators: [Payments.Operator] {
        
        switch self {
        case .fns: return [.fns, .fnsUin]
        case .fms: return [.fms]
        case .fssp: return [.fssp]
        case .sfp: return [.sfp]
        case .direct: return [.direct]
        }
    }
    
    var id: String { "service_\(rawValue)"}
    
    var name: String {
        
        switch self {
        case .fns: return "ФНС"
        case .fms: return "ФМС"
        case .fssp: return "ФССП"
        case .sfp: return "Перевод по номеру телефона"
        default: return "UNKNOWN"
        }
    }
    
    var transferType: Payments.Operation.TransferType {
        
        switch self {
        case .fms, .fns, .fssp : return .anyway
        case .sfp: return .sfp
        case .direct: return .direct
        }
    }
}
