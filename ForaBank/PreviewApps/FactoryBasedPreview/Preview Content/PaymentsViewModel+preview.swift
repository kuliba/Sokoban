//
//  PaymentsViewModel+preview.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 24.04.2024.
//

extension PaymentsViewModel {
    
    static func preview(
        initialState: PaymentsState = .preview(),
        effectHandler: PrepaymentFlowEffectHandler = .preview
    ) -> Self {
        
        let reducer = PrepaymentFlowReducer()
        
        return .init(
            initialState: initialState,
            prepaymentFlowManager: .init(
                reduce: reducer.reduce(_:_:),
                handleEffect: effectHandler.handleEffect(_:_:)
            ),
            spinner: { _ in }
        )
    }
}
