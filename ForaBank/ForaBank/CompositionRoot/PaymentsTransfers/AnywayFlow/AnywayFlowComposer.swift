//
//  AnywayFlowComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.08.2024.
//

import CombineSchedulers
import Foundation

final class AnywayFlowComposer {
    
    private let composer: Composer
    private let fraudDelay: Double
    private let model: Model
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    init(
        composer: Composer,
        fraudDelay: Double = 120,
        model: Model,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.composer = composer
        self.fraudDelay = fraudDelay
        self.model = model
        self.scheduler = scheduler
    }
    
    typealias Composer = AnywayTransactionViewModelComposer
}

extension AnywayFlowComposer {
    
    func compose(
        transaction: AnywayTransactionState.Transaction
    ) -> AnywayFlowModel {
        
        let initialState = makeInitialState(
            transaction: transaction,
            destination: nil
        )
        
        return .init(
            initialState: initialState,
            factory: makeAnywayFlowModelFactory(),
            scheduler: scheduler
        )
    }
}

private extension AnywayFlowComposer {
    
    func makeInitialState(
        transaction: AnywayTransactionState.Transaction,
        destination: AnywayFlowState.Status?
    ) -> AnywayFlowModel.State {
        
        return .init(
            content: composer.compose(transaction: transaction),
            status: destination
        )
    }
    
    func makeAnywayFlowModelFactory(
    ) -> AnywayFlowModelFactory {
        
        return .init(
            getFormattedAmount: getFormattedAmount,
            makeFraud: makeFraudNoticePayload
        )
    }
    
    func getFormattedAmount(
        transaction: AnywayTransactionState.Transaction
    ) -> String? {
        
        model.getFormattedAmount(context: transaction.context)
    }
    
    func makeFraudNoticePayload(
        transaction: AnywayTransactionState.Transaction
    ) -> FraudNoticePayload? {
        
        let payload = transaction.context.outline.payload
        
        return .init(
            title: payload.title,
            subtitle: payload.subtitle,
            formattedAmount: getFormattedAmount(transaction: transaction) ?? "",
            delay: fraudDelay
        )
    }
}
