//
//  AnywayFlowFlowFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.08.2024.
//

struct AnywayFlowFlowFactory {
    
    let getFormattedAmount: GetFormattedAmount
    let makeFraud: MakeFraud
}

extension AnywayFlowFlowFactory {
    
    typealias GetFormattedAmount = (AnywayTransactionState.Transaction) -> String?
    typealias MakeFraud = (AnywayTransactionState.Transaction) -> FraudNoticePayload?
}
