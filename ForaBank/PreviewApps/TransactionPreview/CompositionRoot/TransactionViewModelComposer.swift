//
//  TransactionViewModelComposer.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 19.05.2024.
//

import AnywayPaymentCore
import AnywayPaymentDomain

final class TransactionViewModelComposer {
    
    private let composeMicroServices: ComposeMicroServices
    
    init(
        composeMicroServices: @escaping ComposeMicroServices
    ) {
        self.composeMicroServices = composeMicroServices
    }
}

extension TransactionViewModelComposer {
    
    func compose(
        initialState: TransactionState
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

extension TransactionViewModelComposer {
    
    typealias ComposeMicroServices = () -> MicroServices
    typealias MicroServices = _TransactionEffectHandlerMicroServices
    
    typealias ViewModel = TransactionViewModel
}

private extension TransactionViewModelComposer {
    
    func composeReducer() -> Reducer {
        
        return .init(
            paymentReduce: paymentReduce,
            stagePayment: stagePayment,
            updatePayment: updatePayment,
            paymentInspector: composePaymentInspector()
        )
    }
    
    typealias Reducer = TransactionReducer<_TransactionReport, Payment, PaymentEvent, PaymentEffect, PaymentDigest, PaymentUpdate>
    typealias EffectHandler = TransactionEffectHandler<_TransactionReport, PaymentDigest, PaymentEffect, PaymentEvent, PaymentUpdate>
}

private extension TransactionViewModelComposer {
    
    func paymentReduce(
        payment: Payment,
        paymentEvent: PaymentEvent
    ) -> (Payment, TransactionEffect<PaymentDigest, PaymentEffect>?) {
        
        #warning("replace with actual behaviour")
        return (payment, nil)
    }
    
    func stagePayment(
        payment: Payment
    ) -> Payment {
        
        #warning("replace with actual behaviour")
        return payment
    }
    
    func updatePayment(
        payment: Payment,
        paymentUpdate: PaymentUpdate
    ) -> Payment {
        
        #warning("replace with actual behaviour")
        return payment
    }
    
    func composePaymentInspector(
    ) -> PaymentInspector<Payment, PaymentDigest> {
        
        #warning("replace with actual behaviour")
        return .init(
            checkFraud: { _ in true },
            getVerificationCode: { _ in .init("123456") },
            makeDigest: { $0 },
            shouldRestartPayment: { _ in false },
            validatePayment: { _ in true }
        )
    }
}
