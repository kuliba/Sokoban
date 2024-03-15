//
//  PaymentsTransfersEvent.swift
//
//
//  Created by Igor Malyarov on 15.03.2024.
//

enum PaymentsTransfersEvent<LastPayment, Operator> {
    
    case back
    case utilityFlow(UtilityFlow)
}

extension PaymentsTransfersEvent {
    
    typealias UtilityFlow = UtilityFlowEvent<LastPayment, Operator>
}

extension PaymentsTransfersEvent: Equatable where LastPayment: Equatable, Operator: Equatable {}
