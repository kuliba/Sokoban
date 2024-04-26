//
//  UtilityPrepaymentPickerEvent.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 25.04.2024.
//

enum UtilityPrepaymentPickerEvent: Equatable {
    
    case addCompany
    case payByInstructions
    case select(Select)
}

extension UtilityPrepaymentPickerEvent {
    
    enum Select: Equatable {
        
        case lastPayment(LastPayment)
        case `operator`(Operator)
    }
}
