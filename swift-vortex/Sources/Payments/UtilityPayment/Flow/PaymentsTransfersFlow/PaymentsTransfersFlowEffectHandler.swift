//
//  PaymentsTransfersFlowEffectHandler.swift
//  
//
//  Created by Igor Malyarov on 15.03.2024.
//

public final class PaymentsTransfersFlowEffectHandler<LastPayment, Operator, Service, StartPaymentResponse>
where Operator: Identifiable {
    
    private let utilityFlowHandleEffect: UtilityFlowHandleEffect
    
    public init(utilityFlowHandleEffect: @escaping UtilityFlowHandleEffect) {
        
        self.utilityFlowHandleEffect = utilityFlowHandleEffect
    }
}

public extension PaymentsTransfersFlowEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .utilityFlow(utilityFlowEffect):
            utilityFlowHandleEffect(utilityFlowEffect) {
                
                dispatch(.utilityFlow($0))
            }
        }
    }
}

public extension PaymentsTransfersFlowEffectHandler {
    
    typealias UtilityDispatch = (UtilityEvent) -> Void
    typealias UtilityFlowHandleEffect = (UtilityEffect, @escaping UtilityDispatch) -> Void
    
    typealias UtilityEvent = UtilityFlowEvent<LastPayment, Operator, Service, StartPaymentResponse>
    typealias UtilityEffect = UtilityFlowEffect<LastPayment, Operator, Service>
    
    typealias Dispatch = (Event) -> Void
    
    typealias State = PaymentsTransfersFlowState
    typealias Event = PaymentsTransfersFlowEvent<LastPayment, Operator, Service, StartPaymentResponse>
    typealias Effect = PaymentsTransfersFlowEffect<LastPayment, Operator, Service>
}
