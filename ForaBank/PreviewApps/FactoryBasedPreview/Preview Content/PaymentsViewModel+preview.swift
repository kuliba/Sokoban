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
        
        let reducer = PaymentsReducer()
        let effectHandler = PaymentsEffectHandler()
        
        return .init(
            initialState: initialState,
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:)
        )
    }
}
