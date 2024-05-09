//
//  UtilityPaymentFlowEvent.UtilityPrepaymentFlowEvent.UtilityPrepaymentPayload+preview.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 07.05.2024.
//

extension UtilityPaymentFlowEvent.UtilityPrepaymentFlowEvent.UtilityPrepaymentPayload
where LastPayment == UtilityServicePaymentFlowPreview.LastPayment,
      Operator == UtilityServicePaymentFlowPreview.Operator {
    
    static var preview: Self {
        
        .init(
            lastPayments: .preview,
            operators: .preview
        )
    }
}
