//
//  LoadablePickerEvent.swift
//  
//
//  Created by Igor Malyarov on 20.08.2024.
//

public enum LoadablePickerEvent<Element> {
    
    case load
    case loaded([Element])
    case select(Element?)
}

extension LoadablePickerEvent: Equatable where Element: Equatable {}
