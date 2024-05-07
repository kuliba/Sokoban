//
//  UtilityPaymentFlowEvent.UtilityPrepaymentPayload+preview.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 07.05.2024.
//

extension UtilityPaymentFlowEvent.UtilityPrepaymentPayload {
    
    static let preview: Self = .init(
        lastPayments: .preview, 
        operators: .preview
    )
}
