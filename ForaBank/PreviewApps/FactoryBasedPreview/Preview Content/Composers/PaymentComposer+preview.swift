//
//  PaymentComposer+preview.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 25.04.2024.
//

extension PaymentsComposer
where DestinationView == PaymentView<UtilityPrepaymentPickerMockView> {
    
    static func preview(
        result: InitiateUtilityPrepaymentResult = .success(.preview)
    ) -> Self {
        
        self.init(
            prepaymentFlowManager: .preview(result),
            makeDestinationView: {
                
                .init(state: $0, event: $1, factory: .preview)
            }
        )
    }
    
    typealias InitiateUtilityPrepaymentResult = PaymentEffectHandler.InitiateUtilityPrepaymentResult
}
