//
//  PaymentType.swift
//  ForaBank
//
//  Created by Mikhail on 23.06.2021.
//

import Foundation

enum PaymentType {
    case contact
    case migAIbank
    case migEvoka
    case migArmBB
    case migArdshin
    
    var puref: String {
        switch self {
        case .contact:
            return "iFora||Addressless"
        case .migAIbank:
            return "iSimpleDirect||TransferIDClient11P"
        case .migEvoka:
            return "iSimpleDirect||TransferEvocaClientP"
        case .migArmBB:
            return "iSimpleDirect||TransferArmBBClientP"
        case .migArdshin:
            return "iSimpleDirect||TransferArdshinClientP"
        }
    }
}
