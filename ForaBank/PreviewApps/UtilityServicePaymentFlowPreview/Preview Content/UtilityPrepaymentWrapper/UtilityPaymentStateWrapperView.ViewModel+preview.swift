//
//  UtilityPaymentStateWrapperView.ViewModel+preview.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 03.05.2024.
//

extension UtilityPrepaymentWrapperView.ViewModel {
    
    static func preview(
        initialState: UtilityPrepaymentState = .preview
    ) -> Self {
        
        let reducer = UtilityPrepaymentReducer()
        let effectHandler = UtilityPrepaymentEffectHandler()
        
        return .init(
            initialState: initialState,
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:)
        )
    }
}
