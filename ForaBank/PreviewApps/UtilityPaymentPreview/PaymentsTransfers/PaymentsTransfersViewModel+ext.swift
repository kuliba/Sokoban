//
//  PaymentsTransfersViewModel+ext.swift
//  UtilityPaymentPreview
//
//  Created by Igor Malyarov on 03.03.2024.
//

extension PaymentsTransfersViewModel {
    
    static func `default`(
        initialState: PaymentsTransfersState = .init(),
        flow: Flow = .happy
    ) -> PaymentsTransfersViewModel {
        
        let reducer = PaymentsTransfersReducer()
        let effectHandler = PaymentsTransfersEffectHandler()
        
        return .init(
            initialState: initialState,
            reduce: reducer.reduce,
            handleEffect: effectHandler.handleEffect
        )
    }
}
