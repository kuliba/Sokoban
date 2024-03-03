//
//  PaymentsTransfersViewModel.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.03.2024.
//

import RxViewModel

typealias PaymentsTransfersViewModel = RxViewModel<PaymentsTransfersState, PaymentsTransfersEvent, PaymentsTransfersEffect>

extension PaymentsTransfersViewModel {
    
    static func `default`(
        initialState: PaymentsTransfersState = .init()
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
