//
//  PaymentsTransfersFlowEffect.swift
//  
//
//  Created by Igor Malyarov on 15.03.2024.
//

public enum PaymentsTransfersFlowEffect<LastPayment, Operator, Service>
where Operator: Identifiable {
    
    case utilityFlow(UtilityFlow)
}

public extension PaymentsTransfersFlowEffect {
    
    typealias UtilityFlow = UtilityFlowEffect<LastPayment, Operator, Service>
}

extension PaymentsTransfersFlowEffect: Equatable where LastPayment: Equatable, Operator: Equatable, Service: Equatable {}
