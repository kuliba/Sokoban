//
//  AnywayTransactionViewModelComposer.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 19.05.2024.
//

import AnywayPaymentCore
import AnywayPaymentDomain

final class AnywayTransactionViewModelComposer {
    
    private let composeMicroServices: ComposeMicroServices
    
    init(
        composeMicroServices: @escaping ComposeMicroServices
    ) {
        self.composeMicroServices = composeMicroServices
    }
}

extension AnywayTransactionViewModelComposer {
    
    func compose(
        initialState: AnywayTransactionState
    ) -> ViewModel {
        
        let reducer = composeReducer()
        let microServices = composeMicroServices()
        let effectHandler = EffectHandler(microServices: microServices)
        
        return .init(
            initialState: initialState,
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:)
        )
    }
}

extension AnywayTransactionViewModelComposer {
    
    typealias ComposeMicroServices = () -> MicroServices
    typealias MicroServices = AnywayTransactionEffectHandlerMicroServices
    
    typealias ViewModel = AnywayTransactionViewModel
}

private extension AnywayTransactionViewModelComposer {
    
    func composeReducer() -> Reducer {
        
        return .init(
            paymentReduce: paymentReduce,
            stagePayment: stagePayment,
            updatePayment: updatePayment,
            paymentInspector: composePaymentInspector()
        )
    }
    
    typealias Reducer = TransactionReducer<Report, AnywayPaymentContext, AnywayPaymentEvent, AnywayPaymentEffect, AnywayPaymentDigest, AnywayPaymentUpdate>
    typealias EffectHandler = TransactionEffectHandler<Report, AnywayPaymentDigest, AnywayPaymentEffect, AnywayPaymentEvent, AnywayPaymentUpdate>
}

private extension AnywayTransactionViewModelComposer {
    
    func paymentReduce(
        payment: AnywayPaymentContext,
        paymentEvent: AnywayPaymentEvent
    ) -> (AnywayPaymentContext, TransactionEffect<AnywayPaymentDigest, AnywayPaymentEffect>?) {
        
#warning("replace with actual behaviour")
        return (payment, nil)
    }
    
    func stagePayment(
        _ context: AnywayPaymentContext
    ) -> AnywayPaymentContext {
        
        context.staging()
    }
    
    func updatePayment(
        _ context: AnywayPaymentContext,
        _ update: AnywayPaymentUpdate
    ) -> AnywayPaymentContext {
        
        return context.update(with: update, and: context.outline)
    }
    
    func composePaymentInspector(
    ) -> PaymentInspector<AnywayPaymentContext, AnywayPaymentDigest> {
        
        return .default
    }
}
