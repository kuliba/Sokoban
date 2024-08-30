//
//  PlainPickerEvent.swift
//
//
//  Created by Igor Malyarov on 30.08.2024.
//

public enum PlainPickerEvent<Element> {
    
    case select(Element?)
}

extension PlainPickerEvent: Equatable where Element: Equatable {}
