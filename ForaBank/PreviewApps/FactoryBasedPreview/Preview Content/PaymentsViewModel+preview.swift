//
//  PaymentsViewModel+preview.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 24.04.2024.
//

extension PaymentsViewModel {
    
    static func preview(
        initialState: PaymentsState = .preview()
    ) -> Self {
        
        let reducer = PaymentFlowReducer()
        let effectHandler = PaymentFlowEffectHandler()
        
        return .init(
            initialState: initialState,
            paymentFlowManager: .init(
                reduce: reducer.reduce(_:_:),
                handleEffect: effectHandler.handleEffect(_:_:)
            ),
            spinner: { _ in }
        )
    }
}
