//
//  Composer+preview.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 25.04.2024.
//

extension Composer {
    
    static func preview(
        result: InitiateUtilityPrepaymentResult = .success(.preview)
    ) -> Self {
        
        .init(paymentsComposer: .init(paymentManager: .preview(result)))
    }
    
    typealias InitiateUtilityPrepaymentResult = PaymentsEffectHandler.InitiateUtilityPrepaymentResult
    
    private convenience init(paymentsComposer: PaymentsComposer) {
        
        self.init(makePaymentsView: paymentsComposer.makePaymentsView)
    }
}
