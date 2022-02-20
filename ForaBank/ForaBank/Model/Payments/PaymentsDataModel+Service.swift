//
//  PaymentsDataModel+Service.swift
//  ForaBank
//
//  Created by Max Gribov on 20.02.2022.
//

import Foundation
import UIKit

extension Payments.Service {
    
    var operators: [Payments.Operator] {
        
        switch self {
        case .fms: return [.fms]
        case .fns: return [.fns, .fnsUin]
        case .fssp: return [.fssp]
        }
    }
    
    var id: String { "service_\(rawValue)"}
    
    var name: String {
        
        switch self {
        case .fms: return "ФМС"
        case .fns: return "ФНС"
        case .fssp: return "ФССП"
        }
    }
}
