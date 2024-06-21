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
    
    private let buttonTitle = "Проверить"
    
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
        
        return .init(
            transaction: transaction,
            mapToModel: { event in { self.elementMapper.map($0, event) }},
            makeAmountViewModel: { event in
                
                self.makeAmountViewModel(
                    event: event,
                    scheduler: scheduler
                )
            },
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: scheduler
        )
    }
    
    typealias EffectHandler = TransactionEffectHandler<AnywayTransactionReport, AnywayPaymentDigest, AnywayPaymentEffect, AnywayPaymentEvent, AnywayPaymentUpdate>
    typealias ReducerComposer = AnywayPaymentTransactionReducerComposer<AnywayTransactionReport>
    
    private func makeAmountViewModel(
        event: @escaping (Decimal) -> Void,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) -> (AnywayTransactionState.Transaction) -> BottomAmountViewModel {
        
        return { transaction in
            
            let digest = transaction.context.makeDigest()
            
            let currency = digest.core?.currency
            let currencySymbol = currency.map(self.getCurrencySymbol) ?? ""
            
            let amount = digest.amount ?? 0
            
            let button = BottomAmount.AmountButton(
                title: self.buttonTitle,
                isEnabled: transaction.isValid
            )
            
            let initialState = BottomAmount(value: amount, button: button, status: nil)
            
            return .init(
                currencySymbol: currencySymbol,
                initialState: initialState,
                scheduler: scheduler
            )
        }
    }
}
