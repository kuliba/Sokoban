//
//  UtilityPaymentFlowEffect.swift
//
//
//  Created by Igor Malyarov on 02.03.2024.
//

import PrePaymentPicker

public enum UtilityPaymentFlowEffect<Operator> 
where Operator: Identifiable {
    
    case prePaymentOptions(PrePaymentOptionsEffect<Operator>)
}

extension UtilityPaymentFlowEffect: Equatable where Operator: Equatable {}
