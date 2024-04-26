//
//  PrepaymentFlowEffectHandler+preview.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 25.04.2024.
//

import Foundation

extension PaymentEffectHandler {
    
    static var preview: Self { preview(.success(.preview)) }
    static var empty: Self { preview(.success(.empty)) }
    static var failing: Self { preview(.failure(initiateFailure)) }
    
    private static var initiateFailure: Error { NSError(domain: "InitiateUtilityPrepayment Failure", code: -1) }
    
    static func preview(
        _ result: InitiateUtilityPrepaymentResult = .success(.preview)
    ) -> Self {
        
        self.init(
            initiateUtilityPrepayment: { completion in
            
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    
                    completion(result)
                }
            }
        )
    }
}
