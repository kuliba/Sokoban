//
//  AnywayTransactionViewModelComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 10.06.2024.
//

import AnywayPaymentCore
import AnywayPaymentDomain
import ForaTools
import PaymentComponents

final class AnywayTransactionViewModelComposer {
    
    private let elementMapper: AnywayElementModelMapper
    private let microServices: MicroServices
    private let spinnerActions: SpinnerActions
    
    init(
        elementMapper: AnywayElementModelMapper,
        microServices: MicroServices,
        spinnerActions: SpinnerActions
    ) {
        self.elementMapper = elementMapper
        self.microServices = microServices
        self.spinnerActions = spinnerActions
    }
    
    typealias MicroServices = AnywayTransactionEffectHandlerMicroServices
    typealias SpinnerActions = RootViewModel.RootActions.Spinner?
}

extension AnywayTransactionViewModelComposer {
    
    func makeAnywayTransactionViewModel(
        transaction: AnywayTransactionState.Transaction,
        notify: @escaping (AnywayTransactionStatus?) -> Void,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) -> AnywayTransactionViewModel {
        
        let effectHandler = EffectHandler(microServices: microServices)
        
        let composer = ReducerComposer()
        let reducer = composer.compose()
        
        let decorator = HandleEffectDecorator(
            decoratee: effectHandler.handleEffect(_:_:),
            decoration: .init(
                onEffectStart: { self.spinnerActions?.show() },
                onEffectFinish: { self.spinnerActions?.hide() }
            )
        )

        return .init(
            transaction: transaction,
            mapToModel: { event in { self.elementMapper.map($0, event) }},
            reduce: reducer.reduce(_:_:),
            handleEffect: decorator.callAsFunction(_:_:),
            observe: notify,
            scheduler: scheduler
        )
    }
    
    typealias EffectHandler = TransactionEffectHandler<AnywayTransactionReport, AnywayPaymentDigest, AnywayPaymentEffect, AnywayPaymentEvent, AnywayPaymentUpdate>
    typealias ReducerComposer = AnywayPaymentTransactionReducerComposer<AnywayTransactionReport>
}
