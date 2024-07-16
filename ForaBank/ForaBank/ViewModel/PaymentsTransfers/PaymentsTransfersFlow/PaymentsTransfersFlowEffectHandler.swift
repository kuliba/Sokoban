//
//  PaymentsTransfersFlowEffectHandler.swift
//  ForaBank
//
//  Created by Igor Malyarov on 08.05.2024.
//

import Foundation

final class PaymentsTransfersFlowEffectHandler<LastPayment, Operator, Service> {
    
    private let microServices: MicroServices
#warning("move to microServices")
    private let utilityEffectHandle: UtilityFlowEffectHandle
    
    init(
        microServices: MicroServices,
        utilityEffectHandle: @escaping UtilityFlowEffectHandle
    ) {
        self.microServices = microServices
        self.utilityEffectHandle = utilityEffectHandle
    }
}

extension PaymentsTransfersFlowEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .delay(event, for: interval):
#warning("replace with scheduler!!")
            DispatchQueue.main.delay(for: interval) { dispatch(event) }
            
        case let .initiatePayment(initiatePayment):
            self.initiatePayment(with: initiatePayment, dispatch)
            
        case let .utilityFlow(effect):
            utilityEffectHandle(effect) { dispatch(.utilityFlow($0)) }
        }
    }
}

extension PaymentsTransfersFlowEffectHandler {
    
    typealias MicroServices = PaymentsTransfersFlowEffectHandlerMicroServices
    
    typealias UtilityFlowEvent = UtilityPaymentFlowEvent<LastPayment, Operator, Service>
    typealias UtilityFlowEffect = UtilityPaymentFlowEffect<LastPayment, Operator, Service>
    typealias UtilityFlowDispatch = (UtilityFlowEvent) -> Void
    typealias UtilityFlowEffectHandle = (UtilityFlowEffect, @escaping UtilityFlowDispatch) -> Void
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = PaymentsTransfersFlowEvent<LastPayment, Operator, Service>
    typealias Effect = PaymentsTransfersFlowEffect<LastPayment, Operator, Service>
}

private extension PaymentsTransfersFlowEffectHandler {
    
    func initiatePayment(
        with initiatePayment: Effect.InitiatePayment,
        _ dispatch: @escaping Dispatch
    ) {
        switch initiatePayment {
        case let .service(.latestPayment(latestPayment)):
            
            self.microServices.initiatePayment(latestPayment) {
                
                dispatch(.paymentFlow(.service($0)))
            }
        }
    }
}
