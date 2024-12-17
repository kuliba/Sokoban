//
//  ServicePaymentFlowReducerFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 25.07.2024.
//

import AnywayPaymentDomain

struct ServicePaymentFlowReducerFactory {
    
    let getFormattedAmount: GetFormattedAmount
    let makeFraudNoticePayload: MakeFraudNoticePayload
}

extension ServicePaymentFlowReducerFactory {
    
    typealias GetFormattedAmount = (AnywayPaymentContext) -> String
    typealias MakeFraudNoticePayload = (AnywayPaymentContext) -> FraudNoticePayload?
}
