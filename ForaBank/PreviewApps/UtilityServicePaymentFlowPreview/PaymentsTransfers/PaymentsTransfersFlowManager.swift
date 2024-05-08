//
//  PaymentsTransfersFlowManager.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 03.05.2024.
//

struct PaymentsTransfersFlowManager<UtilityPrepaymentViewModel, PaymentViewModel> {
    
    let handleEffect: HandleEffect
    let makeReduce: MakeReduce
}

extension PaymentsTransfersFlowManager {
    
    typealias Dispatch = (Event) -> Void
    typealias HandleEffect = (Effect, @escaping Dispatch) -> Void
    
    typealias Reduce = (State, Event) -> (State, Effect?)
    typealias Notify = (PaymentStateProjection) -> Void
    typealias MakeReduce = (@escaping Notify) -> Reduce
    
    typealias State = PaymentsTransfersViewModel._Route<UtilityPrepaymentViewModel, PaymentViewModel>
    typealias Event = PaymentsTransfersEvent<UtilityPrepaymentViewModel, PaymentViewModel>
    typealias Effect = PaymentsTransfersEffect<UtilityPrepaymentViewModel, PaymentViewModel>
}
