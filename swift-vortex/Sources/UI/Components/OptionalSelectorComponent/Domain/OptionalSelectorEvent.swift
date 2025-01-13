//
//  OptionalSelectorEvent.swift
//
//
//  Created by Igor Malyarov on 08.08.2024.
//

public enum OptionalSelectorEvent<Item> {
    
    case search(String)
    case select(Item?)
    case toggleOptions
}

extension OptionalSelectorEvent: Equatable where Item: Equatable {}
