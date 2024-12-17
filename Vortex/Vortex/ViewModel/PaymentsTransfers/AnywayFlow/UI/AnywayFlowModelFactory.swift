//
//  AnywayFlowModelFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.08.2024.
//

struct AnywayFlowModelFactory {
    
    let getFormattedAmount: GetFormattedAmount
    let makeFraud: MakeFraud
}

extension AnywayFlowModelFactory {
    
    typealias GetFormattedAmount = (AnywayTransactionState.Transaction) -> String?
    typealias MakeFraud = (AnywayTransactionState.Transaction) -> FraudNoticePayload?
}
