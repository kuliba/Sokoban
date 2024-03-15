//
//  PaymentsTransfersEffect.swift
//  
//
//  Created by Igor Malyarov on 15.03.2024.
//

enum PaymentsTransfersEffect {
    
    case utilityFlow(UtilityFlow)
}

extension PaymentsTransfersEffect {
    
    typealias UtilityFlow = UtilityFlowEffect
}

extension PaymentsTransfersEffect: Equatable {}
