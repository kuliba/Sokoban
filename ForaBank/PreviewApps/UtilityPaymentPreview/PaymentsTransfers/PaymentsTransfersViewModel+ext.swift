//
//  PaymentsTransfersViewModel+ext.swift
//  UtilityPaymentPreview
//
//  Created by Igor Malyarov on 03.03.2024.
//

import Foundation
import UtilityPayment

extension PaymentsTransfersViewModel {
    
    static func `default`(
        initialState: PaymentsTransfersState = .init(),
        flow: Flow = .happy
    ) -> PaymentsTransfersViewModel {
        
        let prePaymentReducer = PrePaymentReducer()
        
        let reducer = PaymentsTransfersReducer(
            prePaymentReduce: prePaymentReducer.reduce
        )
        
        let loadPrePayment: PaymentsTransfersEffectHandler.LoadPrePayment = { completion in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                
                completion(flow.loadPrePayment.result)
            }
        }
        
        let effectHandler = PaymentsTransfersEffectHandler(
            loadPrePayment: loadPrePayment
        )
        
        return .init(
            initialState: initialState,
            reduce: reducer.reduce,
            handleEffect: effectHandler.handleEffect
        )
    }
}

private extension Flow.LoadPrePayment {
    
    var result: Result<PaymentsTransfersEvent.PrePayment, SimpleServiceFailure> {
        
        switch self {
        case .success:
            return .success(.init())
            
        case .failure:
            return .failure(.init())
        }
    }
}
