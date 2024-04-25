//
//  PaymentComposer+preview.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 25.04.2024.
//

extension PaymentsComposer {
    
    static func preview(
        result: InitiateUtilityPaymentResult = .success(.preview)
    ) -> Self {
        
        self.init(
            paymentFlowEffectHandler: .preview(result),
            paymentsDestinationFactory: .preview
        )
    }
    
    typealias InitiateUtilityPaymentResult = PaymentFlowEffectHandler.InitiateUtilityPaymentResult
}
