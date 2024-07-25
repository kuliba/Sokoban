//
//  ServicePaymentFlowReducerFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 25.07.2024.
//

struct ServicePaymentFlowReducerFactory {
    
    let getFormattedAmount: GetFormattedAmount
    let makeFraud: MakeFraudNoticePayload
}

extension ServicePaymentFlowReducerFactory {
    
    typealias GetFormattedAmount = (State) -> String
    typealias MakeFraudNoticePayload = (State) -> FraudNoticePayload?
    
    typealias State = ServicePaymentFlowState
}
