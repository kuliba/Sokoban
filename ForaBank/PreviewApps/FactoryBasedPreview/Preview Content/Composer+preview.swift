//
//  Composer+preview.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 25.04.2024.
//

extension Composer {
    
    static func preview(
        result: InitiateUtilityPaymentResult = .success(.preview)
    ) -> Self {
        
        .init(paymentsComposer: .preview(result: result))
    }
    
    typealias InitiateUtilityPaymentResult = PaymentFlowEffectHandler.InitiateUtilityPaymentResult
    
    private convenience init(paymentsComposer: PaymentsComposer) {
        
        self.init(makePaymentsView: paymentsComposer.makePaymentsView)
    }
}
