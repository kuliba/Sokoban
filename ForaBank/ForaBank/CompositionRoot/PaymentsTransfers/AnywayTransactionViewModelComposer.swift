//
//  AnywayTransactionViewModelComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 10.06.2024.
//

import AnywayPaymentCore
import AnywayPaymentDomain
import ForaTools
import Foundation
import PaymentComponents

final class AnywayTransactionViewModelComposer {
    
    private let getCurrencySymbol: GetCurrencySymbol
    private let elementMapper: AnywayElementModelMapper
    private let microServices: MicroServices
    private let spinnerActions: SpinnerActions
    
    private let buttonTitle = "Продолжить"
    
    init(
        getCurrencySymbol: @escaping GetCurrencySymbol,
        elementMapper: AnywayElementModelMapper,
        microServices: MicroServices,
        spinnerActions: SpinnerActions
    ) {
        self.getCurrencySymbol = getCurrencySymbol
        self.elementMapper = elementMapper
        self.microServices = microServices
        self.spinnerActions = spinnerActions
    }
    
    typealias GetCurrencySymbol = (String) -> String
    typealias MicroServices = AnywayTransactionEffectHandlerMicroServices
    typealias SpinnerActions = RootViewModel.RootActions.Spinner?
}

extension AnywayTransactionViewModelComposer {
    
    func makeAnywayTransactionViewModel(
        transaction: AnywayTransactionState.Transaction,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) -> AnywayTransactionViewModel {
        
        let effectHandler = EffectHandler(microServices: microServices)
        
        let composer = ReducerComposer()
        let reducer = composer.compose()
        
        let footer = makeFooterViewModel(
            transaction: transaction,
            scheduler: scheduler
        )
        
        return .init(
            transaction: transaction,
            mapToModel: { event in { self.elementMapper.map($0, event) }},
            footer: footer,
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: scheduler
        )
    }
    
    typealias EffectHandler = TransactionEffectHandler<AnywayTransactionReport, AnywayPaymentDigest, AnywayPaymentEffect, AnywayPaymentEvent, AnywayPaymentUpdate>
    typealias ReducerComposer = AnywayPaymentTransactionReducerComposer<AnywayTransactionReport>
    
    private func makeFooterViewModel(
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
}
