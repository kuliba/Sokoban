//
//  PrepaymentFlowEffectHandler.InitiateUtilityPaymentResponse+preview.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 25.04.2024.
//

extension PrepaymentFlowEffectHandler.InitiateUtilityPrepaymentResponse {
    
    static let preview: Self = .init(lastPayments: .preview, operators: .preview)
    static let empty: Self = .init(lastPayments: [], operators: [])
}
