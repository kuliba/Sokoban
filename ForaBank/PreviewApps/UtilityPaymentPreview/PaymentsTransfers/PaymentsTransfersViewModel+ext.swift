//
//  PaymentsTransfersViewModel+ext.swift
//  UtilityPaymentPreview
//
//  Created by Igor Malyarov on 03.03.2024.
//

import Foundation

extension PaymentsTransfersViewModel {
    
    static func `default`(
        initialState: PaymentsTransfersState = .init(),
        flow: Flow = .happy
    ) -> PaymentsTransfersViewModel {
        
        let loadPrePayment: PaymentsTransfersEffectHandler.LoadPrePayment = { completion in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                
                completion(flow.loadPrePayment.result)
            }
        }
        
        let reducer = PaymentsTransfersReducer()
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
    
    var result: Result<PaymentsTransfersEvent.PrePayment, ServiceFailure> {
        
        switch self {
        case .success:
            return .success(.init())

        case .connectivity:
            return .failure(.connectivityError)

        case .serverError:
            return .failure(.serverError("Error #12345."))
        }
    }
}
