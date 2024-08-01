//
//  PaymentsTransfersFlowManager.swift
//  ForaBank
//
//  Created by Igor Malyarov on 08.05.2024.
//

import Foundation
struct PaymentsTransfersFlowManager {
    
    let handleEffect: HandleEffect
    let makeReduce: MakeReduce
}

extension PaymentsTransfersFlowManager {
    
    typealias Dispatch = (Event) -> Void
    typealias HandleEffect = (Effect, @escaping Dispatch) -> Void
    
    typealias Reduce = (State, Event) -> (State, Effect?)
    typealias CloseAction = () -> Void
    typealias Notify = (AnywayTransactionStatus?) -> Void
    typealias MakeReduce = (@escaping CloseAction, @escaping Notify) -> Reduce
    
    typealias State = PaymentsTransfersViewModel.Route
    typealias Event = PaymentsTransfersFlowEvent<LastPayment, Operator, Service>
    typealias Effect = PaymentsTransfersFlowEffect<LastPayment, Operator, Service>
    
    typealias LastPayment = UtilityPaymentLastPayment
    typealias Operator = UtilityPaymentOperator
    typealias Service = UtilityService
}
