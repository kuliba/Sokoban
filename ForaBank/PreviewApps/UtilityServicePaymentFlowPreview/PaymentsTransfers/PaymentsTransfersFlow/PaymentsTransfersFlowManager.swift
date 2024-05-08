//
//  PaymentsTransfersFlowManager.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 03.05.2024.
//

struct PaymentsTransfersFlowManager<Content, PaymentViewModel> {
    
    let handleEffect: HandleEffect
    let makeReduce: MakeReduce
}

extension PaymentsTransfersFlowManager {
    
    typealias Dispatch = (Event) -> Void
    typealias HandleEffect = (Effect, @escaping Dispatch) -> Void
    
    typealias Reduce = (State, Event) -> (State, Effect?)
    typealias Notify = (PaymentStateProjection) -> Void
    typealias MakeReduce = (@escaping Notify) -> Reduce
    
    typealias State = PaymentsTransfersViewModel._Route<Content, PaymentViewModel>
    typealias Event = PaymentsTransfersFlowEvent<Content, PaymentViewModel>
    typealias Effect = PaymentsTransfersFlowEffect<Content, PaymentViewModel>
}
