//
//  PickerFlowEffect.swift
//
//
//  Created by Igor Malyarov on 30.08.2024.
//

public enum PickerFlowEffect<Element> {
    
    case select(Element)
}

extension PickerFlowEffect: Equatable where Element: Equatable {}
