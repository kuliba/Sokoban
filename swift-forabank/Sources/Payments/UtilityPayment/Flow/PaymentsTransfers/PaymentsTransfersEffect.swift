//
//  PaymentsTransfersEffect.swift
//  
//
//  Created by Igor Malyarov on 15.03.2024.
//

public enum PaymentsTransfersEffect<LastPayment, Operator, Service> {
    
    case utilityFlow(UtilityFlow)
}

public extension PaymentsTransfersEffect {
    
    typealias UtilityFlow = UtilityFlowEffect<LastPayment, Operator, Service>
}

extension PaymentsTransfersEffect: Equatable where LastPayment: Equatable, Operator: Equatable, Service: Equatable {}
