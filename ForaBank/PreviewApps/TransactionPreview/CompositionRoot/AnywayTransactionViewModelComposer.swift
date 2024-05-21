//
//  AnywayTransactionViewModelComposer.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 19.05.2024.
//

import AnywayPaymentCore
import AnywayPaymentDomain

final class AnywayTransactionViewModelComposer {
    
    private let microServices: MicroServices
    
    init(microServices: MicroServices) {
        
        self.microServices = microServices
    }
}

extension AnywayTransactionViewModelComposer {
    
    func compose(
        initialState: AnywayTransactionState
    ) -> ViewModel {
        
        let effectHandler = EffectHandler(microServices: microServices)
        
        return .init(
            initialState: initialState,
            reduce: Reducer.anyway().reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:)
        )
    }
}

extension AnywayTransactionViewModelComposer {
    
    typealias MicroServices = AnywayTransactionEffectHandlerMicroServices
    
    typealias ViewModel = AnywayTransactionViewModel
}

private extension AnywayTransactionViewModelComposer {
    
    typealias Reducer = TransactionReducer<Report, AnywayPaymentContext, AnywayPaymentEvent, AnywayPaymentEffect, AnywayPaymentDigest, AnywayPaymentUpdate>
    typealias EffectHandler = TransactionEffectHandler<Report, AnywayPaymentDigest, AnywayPaymentEffect, AnywayPaymentEvent, AnywayPaymentUpdate>
}
