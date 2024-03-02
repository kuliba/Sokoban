//
//  PickerState.swift
//
//
//  Created by Igor Malyarov on 02.03.2024.
//

public enum PickerState<LastPayment, Operator> {
    
    case options(OptionsState)
    case selected(Selection)
}

public extension PickerState {
    
    typealias OptionsState = UtilityPaymentsState<LastPayment, Operator>
    
    enum Selection {
        
        case lastPayment(LastPayment)
        case `operator`(Operator)
    }
}

extension PickerState: Equatable where LastPayment: Equatable, Operator: Equatable {}

extension PickerState.Selection: Equatable where LastPayment: Equatable, Operator: Equatable {}
