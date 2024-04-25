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
