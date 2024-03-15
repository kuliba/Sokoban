//
//  UtilityFlowEffect.swift
//  
//
//  Created by Igor Malyarov on 15.03.2024.
//

import UtilityPayment

enum UtilityFlowEffect<LastPayment, Operator> {
    
    case initiate
    case select(Select)
}

extension UtilityFlowEffect {
    
    enum Select {
        
        case last(LastPayment)
        case `operator`(Operator)
    }
}

extension UtilityFlowEffect: Equatable where LastPayment: Equatable, Operator: Equatable {}
extension UtilityFlowEffect.Select: Equatable where LastPayment: Equatable, Operator: Equatable {}
