//
//  PrePaymentPickerEvent.swift
//
//
//  Created by Igor Malyarov on 02.03.2024.
//

public enum PrePaymentPickerEvent<LastPayment, Operator>
where Operator: Identifiable {
    
    case options(OptionsEvent)
    case select(SelectEvent)
}

public extension PrePaymentPickerEvent {
    
    typealias OptionsEvent = PrePaymentOptionsEvent<LastPayment, Operator>
    
    enum SelectEvent {
        
        case lastPayment(LastPayment)
        case `operator`(Operator)
    }
}

extension PrePaymentPickerEvent.SelectEvent: Equatable where LastPayment: Equatable, Operator: Equatable {}

extension PrePaymentPickerEvent: Equatable where LastPayment: Equatable, Operator: Equatable {}
