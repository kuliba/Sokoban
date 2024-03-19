//
//  PaymentsTransfersFlowEvent.swift
//
//
//  Created by Igor Malyarov on 15.03.2024.
//

public enum PaymentsTransfersFlowEvent<LastPayment, Operator, Service, StartPaymentResponse>
where Operator: Identifiable {
    
    case back
    case utilityFlow(UtilityFlow)
}

public extension PaymentsTransfersFlowEvent {
    
    typealias UtilityFlow = UtilityFlowEvent<LastPayment, Operator, Service, StartPaymentResponse>
}

extension PaymentsTransfersFlowEvent: Equatable where LastPayment: Equatable, Operator: Equatable, Service: Equatable, StartPaymentResponse: Equatable {}
