//
//  PaymentsComposer.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 25.04.2024.
//

import SwiftUI

final class PaymentsComposer<DestinationView>
where DestinationView: View {
    
    private let prepaymentFlowManager: PaymentManager
    private let makeDestinationView: MakeDestinationView
    
    init(
        prepaymentFlowManager: PaymentManager,
        makeDestinationView: @escaping MakeDestinationView
    ) {
        self.prepaymentFlowManager = prepaymentFlowManager
        self.makeDestinationView = makeDestinationView
    }
}

extension PaymentsComposer {
    
    func makePaymentsView(
        initialState: PaymentsState = .init(),
        rootEvent: @escaping (RootEvent) -> Void
    ) -> PaymentsView {
        
        let viewModel = PaymentsViewModel(
            initialState: initialState,
            paymentManager: prepaymentFlowManager,
            rootEvent: rootEvent
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
    
    typealias MakeDestinationView = (PaymentsState.Destination, @escaping (PaymentEvent) -> Void) -> DestinationView
    
    typealias PaymentsView = PaymentsStateWrapperView<DestinationView, PaymentButtonLabel>
}
