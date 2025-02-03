//
//  AnywayTransactionViewModelComposer.swift
//  Vortex
//
//  Created by Igor Malyarov on 25.07.2024.
//

import AnywayPaymentCore
import AnywayPaymentDomain
import CombineSchedulers
import Foundation
import PaymentComponents
import VortexTools

final class AnywayTransactionViewModelComposer {
    
    private let model: Model
    private let httpClient: HTTPClient
    private let log: Log
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    private let buttonTitle = "Продолжить"
    
    init(
        model: Model,
        httpClient: HTTPClient,
        log: @escaping Log,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.model = model
        self.httpClient = httpClient
        self.log = log
        self.scheduler = scheduler
    }
    
    typealias Log = (LoggerAgentLevel, LoggerAgentCategory, String, StaticString, UInt) -> Void
}

extension AnywayTransactionViewModelComposer {
    
    func compose(
        transaction: AnywayTransactionState.Transaction
    ) -> AnywayTransactionViewModel {
        
        typealias EffectHandler = TransactionEffectHandler<AnywayTransactionReport, AnywayPaymentDigest, AnywayPaymentEffect, AnywayPaymentEvent, AnywayPaymentUpdate>
        typealias ReducerComposer = AnywayPaymentTransactionReducerComposer<AnywayTransactionReport>
        
        let elementMapper = AnywayElementModelMapper(
            currencyOfProduct: currencyOfProduct(product:),
            format: format(currency:amount:),
            getProducts: model.productSelectProducts,
            makeContacts: makeContacts
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
    
    func currencyOfProduct(
        product: ProductSelect.Product
    ) -> String {
        
        return model.currencyOf(product: product) ?? ""
    }
    
    func format(
        currency: String?,
        amount: Decimal
    ) -> String {
        
        return model.formatted(amount, with: currency ?? "") ?? ""
    }
    
    func makeContacts() -> ContactsViewModel {
        
        model.makeContactsViewModel(forMode: .select(.contacts))
    }
    
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
        
        return model.dictionaryCurrencySymbol(for: currency) ?? ""
    }
}
