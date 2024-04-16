//
//  PrePaymentPickerEffect.swift
//
//
//  Created by Igor Malyarov on 02.03.2024.
//

public enum PrePaymentPickerEffect<Operator>
where Operator: Identifiable {
    
    case options(OptionsEffect)
}

public extension PrePaymentPickerEffect {
    
    typealias OptionsEffect = PrePaymentOptionsEffect<Operator>
}

extension PrePaymentPickerEffect: Equatable where Operator: Equatable {}
