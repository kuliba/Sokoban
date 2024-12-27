//
//  UtilityPrepaymentFlowEffect.swift
//  Vortex
//
//  Created by Igor Malyarov on 13.06.2024.
//

enum UtilityPrepaymentFlowEffect<LastPayment, Operator, Service> {
    
    case initiate(LegacyPaymentPayload)
    case select(Select)
}

extension UtilityPrepaymentFlowEffect {
    
    struct LegacyPaymentPayload {
        
        let type: PTSectionPaymentsView.ViewModel.PaymentsType
        let navLeadingAction: () -> Void
        let navTrailingAction: () -> Void
        let addCompany: () -> Void
        let requisites: () -> Void
    }
    
    typealias Select = Domain.Select
    typealias Domain = InitiateAnywayPaymentDomain<LastPayment, Operator, Service>
}
