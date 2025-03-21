//
//  LoadableEffectHandler.swift
//
//
//  Created by Igor Malyarov on 20.03.2025.
//

/// Handles the side effects associated with loadable state transitions.
public final class LoadableEffectHandler<Resource, Failure: Error> {
    
    /// A closure that performs the loading operation and returns a result asynchronously.
    private let load: Load
    
    /// Initializes the effect handler with a given load operation.
    /// - Parameter load: A closure that asynchronously loads a resource and returns a result.
    public init(load: @escaping Load) {
        self.load = load
    }
    
    /// Defines a type alias for the load operation.
    /// The operation completes asynchronously with a `Result` containing the loaded resource or a failure.
    public typealias Load = (@escaping (Result<Resource, Failure>) -> Void) -> Void
}

public extension LoadableEffectHandler {
    
    /// Handles an effect and dispatches the corresponding event.
    /// - Parameters:
    ///   - effect: The effect to be handled.
    ///   - dispatch: A closure to dispatch the resulting event.
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case .load:
            load { dispatch(.loaded($0)) }
        }
    }
}

public extension LoadableEffectHandler {
    
    /// Defines a type alias for the dispatch function that processes events.
    typealias Dispatch = (Event) -> Void
    
    /// Defines a type alias for events that can be handled by the effect handler.
    typealias Event = LoadableEvent<Resource, Failure>
    
    /// Defines a type alias for effects that can be processed.
    typealias Effect = LoadableEffect
}
