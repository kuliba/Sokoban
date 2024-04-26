//
//  UtilityServicePrepaymentEvent.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 25.04.2024.
//

enum UtilityServicePrepaymentEvent: Equatable {
    
    case addCompany
    case payByInstructions
    case select(Select)
}

extension UtilityServicePrepaymentEvent {
    
    enum Select: Equatable {
        
        case lastPayment(LastPayment)
        case `operator`(Operator)
    }
}
