//
//  UtilityPaymentFlowEffect.swift
//  ForaBank
//
//  Created by Igor Malyarov on 08.05.2024.
//

enum UtilityPaymentFlowEffect<LastPayment, Operator, UtilityService> {
    
    case prepayment(UtilityPrepaymentFlowEffect)
}

extension UtilityPaymentFlowEffect {
    
    enum UtilityPrepaymentFlowEffect {
        
        case initiate(LegacyPaymentPayload)
        case startPayment(with: Select)
    }
}

extension UtilityPaymentFlowEffect.UtilityPrepaymentFlowEffect {
    
    struct LegacyPaymentPayload {
        
        let type: PTSectionPaymentsView.ViewModel.PaymentsType
        let navLeadingAction: () -> Void
        let navTrailingAction: () -> Void
        let addCompany: () -> Void
        let requisites: () -> Void
    }
    
    typealias Select = Event.Select
    typealias Event = UtilityPrepaymentFlowEvent<LastPayment, Operator, UtilityService>
}
