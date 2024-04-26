//
//  PaymentManager+preview.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 25.04.2024.
//

import Foundation

extension PaymentManager {
    
    static var preview: Self { preview(.success(.preview)) }
    static var empty: Self { preview(.success(.empty)) }
    static var failing: Self { preview(.failure(initiateFailure)) }
    
    private static var initiateFailure: Error { NSError(domain: "InitiateUtilityPrepayment Failure", code: -1) }
    
    static func preview(
        _ result: InitiateUtilityPrepaymentResult
    ) -> Self {
        
        let reducer = PaymentReducer()
        let effectHandler = PaymentEffectHandler(
            initiateUtilityPrepayment: { completion in
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    
                    completion(result)
                }
            }
        )
        return .init(
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:)
        )
    }
    
    typealias InitiateUtilityPrepaymentResult = PaymentEffectHandler.InitiateUtilityPrepaymentResult
}
