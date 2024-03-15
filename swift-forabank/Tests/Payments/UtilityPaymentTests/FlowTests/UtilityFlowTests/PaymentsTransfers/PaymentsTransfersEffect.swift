//
//  PaymentsTransfersEffect.swift
//  
//
//  Created by Igor Malyarov on 15.03.2024.
//

enum PaymentsTransfersEffect<LastPayment, Operator> {
    
    case utilityFlow(UtilityFlow)
}

extension PaymentsTransfersEffect {
    
    typealias UtilityFlow = UtilityFlowEffect<LastPayment, Operator>
}

extension PaymentsTransfersEffect: Equatable where LastPayment: Equatable, Operator: Equatable {}
