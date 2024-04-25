//
//  PaymentComposer+preview.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 25.04.2024.
//

extension PaymentsComposer {
    
    static func preview(
        result: InitiateUtilityPrepaymentResult = .success(.preview)
    ) -> Self {
        
        self.init(
            prepaymentFlowEffectHandler: .preview(result),
            makeDestinationView: {
                
                .init(state: $0, factory: .preview)
            }
        )
    }
    
    typealias InitiateUtilityPrepaymentResult = PrepaymentFlowEffectHandler.InitiateUtilityPrepaymentResult
}
