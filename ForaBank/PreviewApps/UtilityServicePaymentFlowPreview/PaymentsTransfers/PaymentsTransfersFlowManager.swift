//
//  PaymentsTransfersFlowManager.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 03.05.2024.
//

struct PaymentsTransfersFlowManager {
    
    let handleEffect: HandleEffect
#warning("replace with closure")
    let makeReducer: MakeReducer
}

extension PaymentsTransfersFlowManager {
    
    typealias Dispatch = (Event) -> Void
    typealias HandleEffect = (Effect, @escaping Dispatch) -> Void
    
    typealias Notify = (PaymentsTransfersReducerFactory.PaymentStateProjection) -> Void
    typealias MakeReducer = (@escaping Notify) -> PaymentsTransfersReducer
    
    typealias Event = PaymentsTransfersEvent
    typealias Effect = PaymentsTransfersEffect
}
