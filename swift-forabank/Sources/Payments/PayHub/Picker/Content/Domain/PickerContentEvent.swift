//
//  PickerContentEvent.swift
//
//
//  Created by Igor Malyarov on 30.08.2024.
//

public enum PickerContentEvent<Element> {
    
    case select(Element?)
}

extension PickerContentEvent: Equatable where Element: Equatable {}
