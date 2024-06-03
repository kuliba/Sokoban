//
//  PaymentsTransfersFlowManager.swift
//  ForaBank
//
//  Created by Igor Malyarov on 08.05.2024.
//

import Foundation
struct PaymentsTransfersFlowManager<LastPayment, Operator, Service, Content, PaymentViewModel> {
    
    let handleEffect: HandleEffect
    let makeReduce: MakeReduce
}

extension PaymentsTransfersFlowManager {
    
    typealias Dispatch = (Event) -> Void
    typealias HandleEffect = (Effect, @escaping Dispatch) -> Void
    
    typealias Reduce = (State, Event) -> (State, Effect?)
    typealias CloseAction = () -> Void
    typealias Notify = (PaymentStateProjection) -> Void
    typealias MakeReduce = (@escaping CloseAction, @escaping Notify) -> Reduce
    
    typealias State = PaymentsTransfersViewModel._Route<LastPayment, Operator, Service, Content, PaymentViewModel>
    typealias Event = PaymentsTransfersFlowEvent<LastPayment, Operator, Service>
    typealias Effect = PaymentsTransfersFlowEffect<LastPayment, Operator, Service>
}
