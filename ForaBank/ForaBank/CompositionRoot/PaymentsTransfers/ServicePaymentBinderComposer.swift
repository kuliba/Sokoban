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
    private let flag: Flag
    private let model: Model
    private let httpClient: HTTPClient
    private let log: Log
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    init(
        fraudDelay: Double,
        flag: Flag,
        model: Model,
        httpClient: HTTPClient,
        log: @escaping Log,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.fraudDelay = fraudDelay
        self.flag = flag
        self.model = model
        self.httpClient = httpClient
        self.log = log
        self.scheduler = scheduler
    }
    
    typealias Flag = UtilitiesPaymentsFlag
    typealias Log = (LoggerAgentLevel, LoggerAgentCategory, String, StaticString, UInt) -> Void
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
        
        let composer = AnywayTransactionViewModelComposer(
            flag: flag,
            model: model,
            httpClient: httpClient,
            log: log,
            scheduler: scheduler
        )
        
        return composer.compose(transaction: transaction)
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
        
        model.getFormattedAmount(context: context) ?? ""
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
