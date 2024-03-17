//
//  PaymentsTransfersEvent.swift
//
//
//  Created by Igor Malyarov on 15.03.2024.
//

public enum PaymentsTransfersEvent<LastPayment, Operator, Service, StartPaymentResponse> {
    
    case back
    case utilityFlow(UtilityFlow)
}

public extension PaymentsTransfersEvent {
    
    typealias UtilityFlow = UtilityFlowEvent<LastPayment, Operator, Service, StartPaymentResponse>
}

extension PaymentsTransfersEvent: Equatable where LastPayment: Equatable, Operator: Equatable, Service: Equatable, StartPaymentResponse: Equatable {}
