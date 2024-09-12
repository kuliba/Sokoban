//
//  AsyncPickerEffectHandlerMicroServices.swift
//
//
//  Created by Igor Malyarov on 24.07.2024.
//

/// A struct representing the micro-services used by `AsyncPickerEffectHandler` for handling load and select operations.
public struct AsyncPickerEffectHandlerMicroServices<Payload, Item, Response> {
    
    /// The load micro-service, which loads items based on a payload.
    let load: Load
    
    /// The select micro-service, which selects an item and returns a response.
    let select: Select
    
    /// Initialises a new instance of the `AsyncPickerEffectHandlerMicroServices`.
    ///
    /// - Parameters:
    ///   - load: The load micro-service.
    ///   - select: The select micro-service.
    public init(
        load: @escaping Load,
        select: @escaping Select
    ) {
        self.load = load
        self.select = select
    }
}

public extension AsyncPickerEffectHandlerMicroServices {
    
    /// A typealias representing the load function, which loads items based on a payload and returns the result via a callback.
    typealias Load = (Payload, @escaping ([Item]) -> Void) -> Void
    
    /// A typealias representing the select function, which selects an item and returns a response via a callback.
    typealias Select = (Item, Payload, @escaping (Response) -> Void) -> Void
}
