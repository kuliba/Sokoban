//
//  UtilityPaymentOperatorPickerEvent.swift
//  NavStackPreview
//
//  Created by Igor Malyarov on 23.04.2024.
//

enum UtilityPaymentOperatorPickerEvent<Icon> {
    
    case addCompany
    case payByInstructions
    case select(Select)
}

extension UtilityPaymentOperatorPickerEvent {
    
    typealias LastPayment = UtilityPaymentOperatorPicker<Icon>.State.LastPayment
    typealias Operator = UtilityPaymentOperatorPicker<Icon>.State.Operator
    
    enum Select {
        
        case lastPayment(LastPayment)
        case `operator`(Operator)
    }
}
