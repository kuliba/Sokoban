//
//  SelectorEvent.swift
//  
//
//  Created by Igor Malyarov on 23.05.2024.
//

public enum SelectorEvent<T> {
    
    case toggleOptions
    case selectOption(T)
    case setSearchQuery(String)
}
