//
//  PaymentsComposer.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 25.04.2024.
//

import SwiftUI

final class PaymentsComposer {
    
    private let paymentManager: PaymentsManager
    
    init(
        paymentManager: PaymentsManager
    ) {
        self.paymentManager = paymentManager
    }
}

extension PaymentsComposer {
    
    func makePaymentsView(
        initialState: PaymentsState = .init(),
        rootActions: @escaping (RootActions) -> Void
    ) -> PaymentsView {
        
        let viewModel = PaymentsViewModel(
            initialState: initialState,
            paymentsManager: paymentManager,
            rootActions: rootActions
        )
        
        let makeDestinationView = makeDestinationView(
            event: { viewModel.event(.payment($0)) }
        )
        
        return .init(
            viewModel: viewModel,
            factory: .init(
                makeDestinationView: makeDestinationView,
                makePaymentButtonLabel: PaymentButtonLabel.init
            )
        )
    }
}

extension PaymentsComposer {
    
    typealias DestinationView = PaymentView<UtilityPrepaymentPickerMockView>
    
    typealias PaymentsView = PaymentsStateWrapperView<DestinationView, PaymentButtonLabel>
}

private extension PaymentsComposer {
    
    func makeDestinationView(
        event: @escaping (PaymentEvent) -> Void
    ) -> (PaymentState) -> DestinationView {
        
        return {
            
            .init(state: $0, event: event, factory: self.makeFactory())
        }
    }
    
    private func makeFactory(
    ) -> PaymentViewFactory<UtilityPrepaymentPickerMockView> {
        
        .init(
            makeUtilityPrepaymentView: { .init(state: $0, event: $1) }
        )
    }
}
