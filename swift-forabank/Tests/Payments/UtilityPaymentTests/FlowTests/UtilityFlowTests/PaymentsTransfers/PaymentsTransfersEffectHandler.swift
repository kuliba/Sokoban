//
//  PaymentsTransfersEffectHandler.swift
//  
//
//  Created by Igor Malyarov on 15.03.2024.
//

final class PaymentsTransfersEffectHandler<LastPayment, Operator, Service, StartPaymentResponse> {
    
    private let utilityFlowHandleEffect: UtilityFlowHandleEffect
    
    init(utilityFlowHandleEffect: @escaping UtilityFlowHandleEffect) {
        
        self.utilityFlowHandleEffect = utilityFlowHandleEffect
    }
}

extension PaymentsTransfersEffectHandler {
    
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

extension PaymentsTransfersEffectHandler {
    
    typealias UtilityDispatch = (UtilityEvent) -> Void
    typealias UtilityFlowHandleEffect = (UtilityEffect, @escaping UtilityDispatch) -> Void
    
    typealias UtilityEvent = UtilityFlowEvent<LastPayment, Operator, Service, StartPaymentResponse>
    typealias UtilityEffect = UtilityFlowEffect<LastPayment, Operator>
    
    typealias Dispatch = (Event) -> Void
    
    typealias State = PaymentsTransfersState
    typealias Event = PaymentsTransfersEvent<LastPayment, Operator, Service, StartPaymentResponse>
    typealias Effect = PaymentsTransfersEffect<LastPayment, Operator>
}
