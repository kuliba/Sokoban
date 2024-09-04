//
//  PlainPickerFlowEffect.swift
//
//
//  Created by Igor Malyarov on 30.08.2024.
//

public enum PlainPickerFlowEffect<Element> {
    
    case select(Element)
}

extension PlainPickerFlowEffect: Equatable where Element: Equatable {}
