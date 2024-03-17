//
//  PaymentsTransfersEffectHandler.swift
//  
//
//  Created by Igor Malyarov on 15.03.2024.
//

public final class PaymentsTransfersEffectHandler<LastPayment, Operator, Service, StartPaymentResponse> {
    
    private let utilityFlowHandleEffect: UtilityFlowHandleEffect
    
    public init(utilityFlowHandleEffect: @escaping UtilityFlowHandleEffect) {
        
        self.utilityFlowHandleEffect = utilityFlowHandleEffect
    }
}

public extension PaymentsTransfersEffectHandler {
    
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

public extension PaymentsTransfersEffectHandler {
    
    typealias UtilityDispatch = (UtilityEvent) -> Void
    typealias UtilityFlowHandleEffect = (UtilityEffect, @escaping UtilityDispatch) -> Void
    
    typealias UtilityEvent = UtilityFlowEvent<LastPayment, Operator, Service, StartPaymentResponse>
    typealias UtilityEffect = UtilityFlowEffect<LastPayment, Operator, Service>
    
    typealias Dispatch = (Event) -> Void
    
    typealias State = PaymentsTransfersState
    typealias Event = PaymentsTransfersEvent<LastPayment, Operator, Service, StartPaymentResponse>
    typealias Effect = PaymentsTransfersEffect<LastPayment, Operator, Service>
}
