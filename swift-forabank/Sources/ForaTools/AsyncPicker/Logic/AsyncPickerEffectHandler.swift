//
//  AsyncPickerEffectHandler.swift
//
//
//  Created by Igor Malyarov on 23.07.2024.
//

/// A handler for managing asynchronous picker effects such as loading and selecting items.
public final class AsyncPickerEffectHandler<Payload, Item, Response> {
    
    /// Micro-services responsible for loading and selecting items.
    private let microServices: MicroServices
    
    /// Initialises a new instance of the `AsyncPickerEffectHandler`.
    ///
    /// - Parameter microServices: The micro-services used for handling load and select operations.
    public init(
        microServices: MicroServices
    ) {
        self.microServices = microServices
    }
    
    /// A typealias representing the micro-services used by the effect handler.
    public typealias MicroServices = AsyncPickerEffectHandlerMicroServices<Payload, Item, Response>
}

public extension AsyncPickerEffectHandler {
    
    /// Handles the specified effect by invoking the appropriate micro-service and dispatching the result.
    ///
    /// - Parameters:
    ///   - effect: The effect to handle.
    ///   - dispatch: The dispatch function used to send events.
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .load(payload):
            microServices.load(payload) { dispatch(.loaded($0)) }
            
        case let .select(item):
            microServices.select(item) { dispatch(.response($0)) }
        }
    }
}

public extension AsyncPickerEffectHandler {
    
    /// A typealias representing the dispatch function used to send events.
    typealias Dispatch = (Event) -> Void
    
    /// A typealias representing events that can be dispatched by the effect handler.
    typealias Event = AsyncPickerEvent<Item, Response>
    
    /// A typealias representing effects that can be handled by the effect handler.
    typealias Effect = AsyncPickerEffect<Payload, Item>
}
