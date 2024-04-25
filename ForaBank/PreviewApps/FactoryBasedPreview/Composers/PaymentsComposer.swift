//
//  PaymentsComposer.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 25.04.2024.
//

import SwiftUI

final class PaymentsComposer {}

extension PaymentsComposer {
    
    func makePaymentsView(
        initialState: PaymentsState = .init(),
        spinner: @escaping (SpinnerEvent) -> Void
    ) -> PaymentsStateWrapperView {
        
        .init(
            viewModel: .init(
                initialState: initialState,
                paymentFlowManager: makePaymentFlowManager(),
                spinner: spinner
            ),
            factory: makeFactory()
        )
    }
}

private extension PaymentsComposer {
    
    func makePaymentFlowManager(
    ) -> PaymentFlowManager {
        
        let reducer = PaymentFlowReducer()
        let effectHandler = PaymentFlowEffectHandler()
        
        return .init(
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:)
        )
    }
    
    func makeFactory(
    ) -> PaymentsViewFactory {
        
        .init(
            makeDestinationView: PaymentsDestinationView.init,
            makePaymentButtonLabel: PaymentButtonLabel.init
        )
    }
}
