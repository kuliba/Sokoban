//
//  PaymentsComposer.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 25.04.2024.
//

import SwiftUI

final class PaymentsComposer {
    
    private let prepaymentFlowEffectHandler: PrepaymentFlowEffectHandler
    private let paymentsDestinationFactory: PaymentsDestinationViewFactory
    
    init(
        prepaymentFlowEffectHandler: PrepaymentFlowEffectHandler,
        paymentsDestinationFactory: PaymentsDestinationViewFactory
    ) {
        self.prepaymentFlowEffectHandler = prepaymentFlowEffectHandler
        self.paymentsDestinationFactory = paymentsDestinationFactory
    }
}

extension PaymentsComposer {
    
    func makePaymentsView(
        initialState: PaymentsState = .init(),
        spinner: @escaping (SpinnerEvent) -> Void
    ) -> PaymentsView {
        
        let viewModel = PaymentsViewModel(
            initialState: initialState,
            prepaymentFlowManager: makePrepaymentFlowManager(),
            spinner: spinner
        )
        
        return .init(
            viewModel: viewModel,
            factory: makeFactory()
        )
    }
    
    typealias PaymentsView = PaymentsStateWrapperView<PaymentsDestinationView, PaymentButtonLabel>
}

private extension PaymentsComposer {
    
    func makePrepaymentFlowManager(
    ) -> PrepaymentFlowManager {
        
        let reducer = PrepaymentFlowReducer()
        
        return .init(
            reduce: reducer.reduce(_:_:),
            handleEffect: prepaymentFlowEffectHandler.handleEffect(_:_:)
        )
    }
    
    func makeFactory(
    ) -> _PaymentsViewFactory {
        
        .init(
            makeDestinationView: {
                
                .init(state: $0, factory: self.paymentsDestinationFactory)
            },
            makePaymentButtonLabel: PaymentButtonLabel.init
        )
    }
    
    typealias _PaymentsViewFactory = PaymentsViewFactory<PaymentsDestinationView, PaymentButtonLabel>
}
