//
//  ServicePaymentBinderComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 25.07.2024.
//

import AnywayPaymentDomain
import CombineSchedulers
import Foundation
import RxViewModel

final class ServicePaymentBinderComposer {
    
    private let fraudDelay: Double
    private let model: Model
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    init(
        fraudDelay: Double,
        model: Model,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.fraudDelay = fraudDelay
        self.model = model
        self.scheduler = scheduler
    }
}

extension ServicePaymentBinderComposer {
    
    func makeBinder(
        transaction: AnywayTransactionState.Transaction,
        initialFlowState: ServicePaymentFlowState = .none
    ) -> ServicePaymentBinder {
        
        return .init(
            content: makeContentModel(transaction: transaction),
            flow: makeFlowModel(initialFlowState: initialFlowState),
            scheduler: scheduler
        )
    }
}

private extension ServicePaymentBinderComposer {
    
    func makeContentModel(
        transaction: AnywayTransactionState.Transaction
    ) -> AnywayTransactionViewModel {
        
        // let composer = AnywayTransactionViewModelComposer()
        fatalError()
    }
    
    func makeFlowModel(
        initialFlowState: ServicePaymentFlowState
    ) -> ServicePaymentFlowModel {
        
        let factory = ServicePaymentFlowReducerFactory(
            getFormattedAmount: getFormattedAmount,
            makeFraudNoticePayload: makeFraudNoticePayload
        )
        let reducer = ServicePaymentFlowReducer(factory: factory)
        
        let effectHandler = ServicePaymentFlowEffectHandler(
            scheduler: scheduler
        )
        
        return .init(
            initialState: initialFlowState,
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: scheduler
        )
    }
}

private extension ServicePaymentBinderComposer {
    
    func getFormattedAmount(
        context: AnywayPaymentContext
    ) -> String {
        
        let digest = context.makeDigest()
        let amount = digest.amount
        let currency = digest.core?.currency
        
        var formattedAmount = amount.map { "\($0)" } ?? ""
        
#warning("look into model to extract currency symbol")
        if let currency {
            formattedAmount += " \(currency)"
            _ = model
        }
        
        return formattedAmount
    }
    
    func makeFraudNoticePayload(
        context: AnywayPaymentContext
    ) -> FraudNoticePayload? {
        
        let payload = context.outline.payload
        
        return .init(
            title: payload.title,
            subtitle: payload.subtitle,
            formattedAmount: getFormattedAmount(context: context),
            delay: fraudDelay
        )
    }
}
