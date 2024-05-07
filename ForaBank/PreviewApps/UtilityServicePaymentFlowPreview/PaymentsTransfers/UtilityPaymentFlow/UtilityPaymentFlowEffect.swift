//
//  UtilityPaymentFlowEffect.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 04.05.2024.
//

enum UtilityPaymentFlowEffect: Equatable {
    
    case initiate
    case prepayment(UtilityPrepaymentFlowEffect)
}

extension UtilityPaymentFlowEffect {
    
    enum UtilityPrepaymentFlowEffect: Equatable {
        
        case startPayment(with: Select)
    }
}

extension UtilityPaymentFlowEffect.UtilityPrepaymentFlowEffect {
    
    typealias Select = UtilityPaymentFlowEvent.UtilityPrepaymentFlowEvent.Select
}
