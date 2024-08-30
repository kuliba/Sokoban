//
//  PlainPickerContentEvent.swift
//
//
//  Created by Igor Malyarov on 30.08.2024.
//

public enum PlainPickerContentEvent<Element> {
    
    case select(Element?)
}

extension PlainPickerContentEvent: Equatable where Element: Equatable {}
