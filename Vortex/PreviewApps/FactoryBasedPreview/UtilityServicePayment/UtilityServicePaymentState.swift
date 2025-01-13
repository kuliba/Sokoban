//
//  UtilityServicePaymentState.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 26.04.2024.
//

enum UtilityServicePaymentState: Equatable {
    
    case prepayment(UtilityServicePrepaymentState)
}
