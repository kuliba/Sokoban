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
            makeFooter: makeFooter(scheduler: scheduler),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: scheduler
        )
    }
    
    typealias EffectHandler = TransactionEffectHandler<AnywayTransactionReport, AnywayPaymentDigest, AnywayPaymentEffect, AnywayPaymentEvent, AnywayPaymentUpdate>
    typealias ReducerComposer = AnywayPaymentTransactionReducerComposer<AnywayTransactionReport>
    
    private func makeFooter(
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) -> AnywayTransactionViewModel.MakeFooter {
        
        return { event in
            
            return { transaction in
                
                let digest = transaction.context.makeDigest()
                
                guard digest.amount != nil,
                      digest.core?.currency != nil
                else { 
                    
                    return .continueButton { event(.buttonTap) }
                }
                
                let node = self.makeBottomAmountNode(
                    transaction: transaction,
                    event: event,
                    scheduler: scheduler
                )
                
                return .amount(node)
            }
        }
    }
    
    private func makeBottomAmountNode(
        transaction: AnywayTransactionViewModel.State.Transaction,
        event: @escaping AnywayTransactionViewModel.NotifyAmount,
        scheduler: AnySchedulerOfDispatchQueue
    ) -> Node<BottomAmountViewModel> {
        
        let digest = transaction.context.makeDigest()
        
        let currency = digest.core?.currency
        let currencySymbol = currency.map(getCurrencySymbol) ?? ""
        
        let amount = digest.amount ?? 0
        
        let button = BottomAmount.AmountButton(
            title: buttonTitle,
            isEnabled: transaction.isValid
        )
        
        let initialState = BottomAmount(
            value: amount,
            button: button,
            status: nil
        )
        
        let viewModel = BottomAmountViewModel(
            currencySymbol: currencySymbol,
            initialState: initialState,
            scheduler: scheduler
        )
        
        print("===>>>", ObjectIdentifier(viewModel), "created BottomAmountViewModel", #file, #line)
        
        let subscription = viewModel.$state
            .map(AnywayTransactionViewModel.AmountEvent.init(bottomAmount:))
            .removeDuplicates()
            .receive(on: scheduler)
            .sink(receiveValue: event)
        
        return .init(model: viewModel, subscription: subscription)
    }
}

private extension AnywayTransactionViewModel.AmountEvent {
    
    init(bottomAmount: BottomAmount) {
        
        if case .tapped = bottomAmount.status {
            self = .buttonTap
        } else {
            self = .edit(bottomAmount.value)
        }
    }
}
