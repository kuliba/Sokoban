//
//  PaymentsComposer.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 25.04.2024.
//

import SwiftUI

final class PaymentsComposer<DestinationView> 
where DestinationView: View {
    
    private let prepaymentFlowManager: PrepaymentFlowManager
    private let makeDestinationView: MakeDestinationView
    
    init(
        prepaymentFlowManager: PrepaymentFlowManager,
        makeDestinationView: @escaping MakeDestinationView
    ) {
        self.prepaymentFlowManager = prepaymentFlowManager
        self.makeDestinationView = makeDestinationView
    }
}

extension PaymentsComposer {
    
    func makePaymentsView(
        initialState: PaymentsState = .init(),
        spinner: @escaping (SpinnerEvent) -> Void
    ) -> PaymentsView {
        
        let viewModel = PaymentsViewModel(
            initialState: initialState,
            prepaymentFlowManager: prepaymentFlowManager,
            spinner: spinner
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
    
    typealias MakeDestinationView = (PaymentsState.Destination) -> DestinationView

    typealias PaymentsView = PaymentsStateWrapperView<DestinationView, PaymentButtonLabel>
}
