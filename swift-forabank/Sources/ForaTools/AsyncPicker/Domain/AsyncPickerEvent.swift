//
//  AsyncPickerEvent.swift
//
//
//  Created by Igor Malyarov on 23.07.2024.
//

/// Represents the events that can occur in the asynchronous picker.
public enum AsyncPickerEvent<Item, Response> {
    
    /// Event to load the picker.
    case load
    
    /// Event indicating the picker has loaded with the given items.
    case loaded([Item])
    
    /// Event indicating a response associated with the picker.
    case response(Response)
    
    /// Event to select an item in the picker.
    case select(Item)
}

extension AsyncPickerEvent: Equatable where Item: Equatable, Response: Equatable {}
