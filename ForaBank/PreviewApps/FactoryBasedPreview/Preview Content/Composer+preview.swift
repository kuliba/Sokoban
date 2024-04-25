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
        
        .init(paymentsComposer: .preview(result: result))
    }
    
    typealias InitiateUtilityPrepaymentResult = PrepaymentFlowEffectHandler.InitiateUtilityPrepaymentResult
    
    private convenience init(paymentsComposer: PaymentsComposer<PaymentsDestinationView<UtilityPrepaymentView>>) {
        
        self.init(makePaymentsView: paymentsComposer.makePaymentsView)
    }
}
