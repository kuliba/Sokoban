//
//  UtilityPaymentFlowEffect.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 04.05.2024.
//

enum UtilityPaymentFlowEffect<LastPayment, Operator, UtilityService> {
    
    case prepayment(UtilityPrepaymentFlowEffect)
}

extension UtilityPaymentFlowEffect {
    
    enum UtilityPrepaymentFlowEffect {
        
        case initiate
        case startPayment(with: Select)
    }
}

extension UtilityPaymentFlowEffect.UtilityPrepaymentFlowEffect {
    
    typealias Event = UtilityPaymentFlowEvent<LastPayment, Operator, UtilityService>
    typealias Select = Event.UtilityPrepaymentFlowEvent.Select
}

extension UtilityPaymentFlowEffect: Equatable where LastPayment: Equatable, Operator: Equatable, UtilityService: Equatable {}
extension UtilityPaymentFlowEffect.UtilityPrepaymentFlowEffect: Equatable where LastPayment: Equatable, Operator: Equatable, UtilityService: Equatable {}
