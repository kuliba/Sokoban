//
//  PaymentsDataModel+Operator.swift
//  ForaBank
//
//  Created by Max Gribov on 20.02.2022.
//

import Foundation

extension Payments.Operator {
    
    var name: String {
        
        switch self {
        case .fms: return "ФМС"
        case .fns: return "ФНС"
        case .fnsUin: return "ФНС по УИН"
        case .fssp: return "ФССП"
        }
    }
}
