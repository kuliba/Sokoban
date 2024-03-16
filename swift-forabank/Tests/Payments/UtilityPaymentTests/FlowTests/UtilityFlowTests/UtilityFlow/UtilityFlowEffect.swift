//
//  UtilityFlowEffect.swift
//  
//
//  Created by Igor Malyarov on 15.03.2024.
//

import UtilityPayment

enum UtilityFlowEffect<LastPayment, Operator, Service> {
    
    case initiate
    case select(Select)
}

extension UtilityFlowEffect {
    
    enum Select {
        
        case last(LastPayment)
        case `operator`(Operator)
        case service(Service, for: Operator)
    }
}

extension UtilityFlowEffect: Equatable where LastPayment: Equatable, Operator: Equatable, Service: Equatable {}
extension UtilityFlowEffect.Select: Equatable where LastPayment: Equatable, Operator: Equatable, Service: Equatable {}
