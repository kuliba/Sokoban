//
//  PaymentsComposer.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 25.04.2024.
//

import SwiftUI

final class PaymentsComposer {

    private let paymentFlowEffectHandler: PaymentFlowEffectHandler
    private let paymentsDestinationFactory: PaymentsDestinationViewFactory
    
    init(
        paymentFlowEffectHandler: PaymentFlowEffectHandler,
        paymentsDestinationFactory: PaymentsDestinationViewFactory
    ) {
        self.paymentFlowEffectHandler = paymentFlowEffectHandler
        self.paymentsDestinationFactory = paymentsDestinationFactory
    }
}

extension PaymentsComposer {
    
    func makePaymentsView(
        initialState: PaymentsState = .init(),
        spinner: @escaping (SpinnerEvent) -> Void
    ) -> PaymentsStateWrapperView {
        
        let viewModel = PaymentsViewModel(
            initialState: initialState,
            paymentFlowManager: makePaymentFlowManager(),
            spinner: spinner
        )
        
        return .init(
            viewModel: viewModel,
            factory: makeFactory()
        )
    }
}

private extension PaymentsComposer {
    
    func makePaymentFlowManager(
    ) -> PaymentFlowManager {
        
        let reducer = PaymentFlowReducer()
        
        return .init(
            reduce: reducer.reduce(_:_:),
            handleEffect: paymentFlowEffectHandler.handleEffect(_:_:)
        )
    }
    
    func makeFactory(
    ) -> PaymentsViewFactory {
        
        .init(
            makeDestinationView: {
                
                .init(state: $0, factory: self.paymentsDestinationFactory)
            },
            makePaymentButtonLabel: PaymentButtonLabel.init
        )
    }
}
