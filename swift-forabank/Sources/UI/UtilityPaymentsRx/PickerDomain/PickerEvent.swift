//
//  PickerEvent.swift
//
//
//  Created by Igor Malyarov on 02.03.2024.
//

public enum PickerEvent<LastPayment, Operator>
where Operator: Identifiable {
    
    case options(OptionsEvent)
    case select(SelectEvent)
}

public extension PickerEvent {
    
    typealias OptionsEvent = UtilityPaymentsEvent<LastPayment, Operator>
    
    enum SelectEvent {
        
        case lastPayment(LastPayment)
        case `operator`(Operator)
    }
}

extension PickerEvent.SelectEvent: Equatable where LastPayment: Equatable, Operator: Equatable {}

extension PickerEvent: Equatable where LastPayment: Equatable, Operator: Equatable {}
