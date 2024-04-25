//
//  PaymentsComposer.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 25.04.2024.
//

import SwiftUI

final class PaymentsComposer {
    
    private let paymentFlowEffectHandler: PaymentFlowEffectHandler
    
    init(
        paymentFlowEffectHandler: PaymentFlowEffectHandler
    ) {
        self.paymentFlowEffectHandler = paymentFlowEffectHandler
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
            makeDestinationView: PaymentsDestinationView.init,
            makePaymentButtonLabel: PaymentButtonLabel.init
        )
    }
}
