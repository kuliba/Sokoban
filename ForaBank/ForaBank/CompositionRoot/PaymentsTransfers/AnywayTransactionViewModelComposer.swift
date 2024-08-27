//
//  AnywayTransactionViewModelComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 25.07.2024.
//

import AnywayPaymentCore
import AnywayPaymentDomain
import CombineSchedulers
import ForaTools
import Foundation
import PaymentComponents

final class AnywayTransactionViewModelComposer {
    
    private let flag: Flag
    private let model: Model
    private let httpClient: HTTPClient
    private let log: Log
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    private let buttonTitle = "Продолжить"
    
    init(
        flag: Flag,
        model: Model,
        httpClient: HTTPClient,
        log: @escaping Log,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.flag = flag
        self.model = model
        self.httpClient = httpClient
        self.log = log
        self.scheduler = scheduler
    }
    
    typealias Flag = UtilitiesPaymentsFlag
    typealias Log = (LoggerAgentLevel, LoggerAgentCategory, String, StaticString, UInt) -> Void
}

extension AnywayTransactionViewModelComposer {
    
    func compose(
        transaction: AnywayTransactionState.Transaction
    ) -> AnywayTransactionViewModel {
        
        typealias EffectHandler = TransactionEffectHandler<AnywayTransactionReport, AnywayPaymentDigest, AnywayPaymentEffect, AnywayPaymentEvent, AnywayPaymentUpdate>
        typealias ReducerComposer = AnywayPaymentTransactionReducerComposer<AnywayTransactionReport>
        
        let elementMapperComposer = AnywayElementModelMapperComposer(model: model)
        let elementMapper = elementMapperComposer.compose(
            flag: flag.optionOrStub
        )
        
        let composer = ReducerComposer()
        let reducer = composer.compose()
        
        let microServices = composeMicroServices()
        let effectHandler = EffectHandler(microServices: microServices)
        
        let footer = makeFooterViewModel(
            transaction: transaction,
            scheduler: scheduler
        )
        
        return .init(
            transaction: transaction,
            mapToModel: { event in { elementMapper.map($0, event) }},
            footer: footer,
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: scheduler
        )
    }
}

private extension AnywayTransactionViewModelComposer {
    
    func makeFooterViewModel(
        transaction: AnywayTransactionState.Transaction,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) -> FooterViewModel {
        
        let digest = transaction.context.makeDigest()
        
        let amount = digest.amount ?? 0
        let currency = digest.core?.currency
        let currencySymbol = currency.map(getCurrencySymbol) ?? "₽"
        
        let footerState = FooterState(
            amount: amount,
            button: .init(
                title: buttonTitle,
                state: transaction.isValid ? .active : .inactive
            ),
            style: .button
        )
        
        return .init(
            initialState: footerState,
            currencySymbol: currencySymbol,
            scheduler: scheduler
        )
    }
    
    private func composeMicroServices(
    ) -> AnywayTransactionEffectHandlerMicroServices {
        
        typealias NanoServicesComposer = AnywayTransactionEffectHandlerNanoServicesComposer
        typealias MicroServicesComposer = AnywayTransactionEffectHandlerMicroServicesComposer
        
        let nanoServicesComposer = NanoServicesComposer(
            flag: flag.optionOrStub,
            httpClient: httpClient,
            log: log
        )
        
        let nanoServices = nanoServicesComposer.compose()
        
        let microServicesComposer = MicroServicesComposer(
            nanoServices: nanoServices
        )
        
        return microServicesComposer.compose()
    }
    
    private func getCurrencySymbol(
        for currency: String
    ) -> String {
        
        model.dictionaryCurrencySymbol(for: currency) ?? ""
    }
}
