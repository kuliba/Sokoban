//
//  AsyncPickerEffect.swift
//
//
//  Created by Igor Malyarov on 23.07.2024.
//

/// Represents the effects that can occur as a result of events in the asynchronous picker.
public enum AsyncPickerEffect<Payload, Item> {
    
    /// Effect to load the picker with the given payload.
    case load(Payload)
    
    /// Effect to select an item in the picker.
    case select(Item)
}

extension AsyncPickerEffect: Equatable where Payload: Equatable, Item: Equatable {}
