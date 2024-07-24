//
//  AsyncPickerState.swift
//
//
//  Created by Igor Malyarov on 23.07.2024.
//

/// Represents the state of an asynchronous picker.
public struct AsyncPickerState<Payload, Item, Response> {
    
    /// The payload associated with the picker.
    public let payload: Payload
    
    /// A flag indicating whether the picker is currently loading.
    public var isLoading: Bool
    
    /// An optional array of items available in the picker.
    public var items: [Item]?
    
    /// An optional response associated with the picker.
    public var response: Response?
    
    /// Initialises a new instance of `AsyncPickerState`.
    /// - Parameters:
    ///   - payload: The payload associated with the picker.
    ///   - isLoading: A flag indicating whether the picker is currently loading. Defaults to `false`.
    ///   - items: An optional array of items available in the picker. Defaults to `nil`.
    ///   - response: An optional response associated with the picker. Defaults to `nil`.
    public init(
        payload: Payload,
        isLoading: Bool = false,
        items: [Item]? = nil,
        response: Response? = nil
    ) {
        self.payload = payload
        self.isLoading = isLoading
        self.items = items
        self.response = response
    }
}

extension AsyncPickerState: Equatable where Payload: Equatable, Item: Equatable, Response: Equatable {}
