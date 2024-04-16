//
//  PrePaymentPickerState.swift
//
//
//  Created by Igor Malyarov on 02.03.2024.
//

public enum PrePaymentPickerState<LastPayment, Operator> {
    
    case options(OptionsState)
    case selected(Selection)
}

public extension PrePaymentPickerState {
    
    typealias OptionsState = PrePaymentOptionsState<LastPayment, Operator>
    
    enum Selection {
        
        case lastPayment(LastPayment)
        case `operator`(Operator)
    }
}

extension PrePaymentPickerState: Equatable where LastPayment: Equatable, Operator: Equatable {}

extension PrePaymentPickerState.Selection: Equatable where LastPayment: Equatable, Operator: Equatable {}
