//
//  PickerEffect.swift
//
//
//  Created by Igor Malyarov on 02.03.2024.
//

public enum PickerEffect<Operator>
where Operator: Identifiable {
    
    case options(OptionsEffect)
}

public extension PickerEffect {
    
    typealias OptionsEffect = UtilityPaymentsEffect<Operator>
}

extension PickerEffect: Equatable where Operator: Equatable {}
