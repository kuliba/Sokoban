//
//  PaymentsComposer.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 25.04.2024.
//

import SwiftUI

final class PaymentsComposer {
    
    private let prepaymentFlowEffectHandler: PrepaymentFlowEffectHandler
    private let makeDestinationView: MakeDestinationView
    
    init(
        prepaymentFlowEffectHandler: PrepaymentFlowEffectHandler,
        makeDestinationView: @escaping MakeDestinationView
    ) {
        self.prepaymentFlowEffectHandler = prepaymentFlowEffectHandler
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
            prepaymentFlowManager: makePrepaymentFlowManager(),
            spinner: spinner
        )
        
        return .init(
            viewModel: viewModel,
            factory: makeFactory()
        )
    }
}

extension PaymentsComposer {
    
    typealias DestinationView = PaymentsDestinationView<UtilityPrepaymentView>
    typealias MakeDestinationView = (PaymentsState.Destination) -> DestinationView
    
    typealias PaymentsDestinationFactory = PaymentsDestinationViewFactory<UtilityPrepaymentView>

    typealias _PaymentsDestinationView = PaymentsDestinationView<UtilityPrepaymentView>
    typealias PaymentsView = PaymentsStateWrapperView<_PaymentsDestinationView, PaymentButtonLabel>
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
            makeDestinationView: makeDestinationView,
            makePaymentButtonLabel: PaymentButtonLabel.init
        )
    }
    
    typealias _PaymentsViewFactory = PaymentsViewFactory<_PaymentsDestinationView, PaymentButtonLabel>
}
