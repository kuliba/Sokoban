//
//  OperationTrackerEffectHandler.swift
//
//
//  Created by Igor Malyarov on 27.08.2024.
//

/// A handler responsible for executing effects and dispatching corresponding events
/// based on the results of those effects in the `OperationTracker`.
public final class OperationTrackerEffectHandler {
    
    /// A closure that performs the loading operation.
    /// The closure accepts a callback that should be invoked with `true` if the load
    /// succeeds and `false` if it fails.
    private let load: Load
    
    /// Initialises the `OperationTrackerEffectHandler` with a specific load operation.
    /// - Parameter load: A closure that performs the load operation and provides the
    /// result via a callback.
    public init(
        load: @escaping Load
    ) {
        self.load = load
    }
    
    /// Typealias representing the load operation, which takes a completion closure
    /// that should be called with a `Bool` indicating the success (`true`) or failure (`false`) of the operation.
    public typealias Load = (@escaping (Bool) -> Void) -> Void
}

public extension OperationTrackerEffectHandler {
    
    /// Handles the given effect and dispatches events based on the outcome of the effect.
    /// - Parameters:
    ///   - effect: The effect to handle, which in this case is typically a `load` operation.
    ///   - dispatch: A closure used to dispatch events such as `loadSuccess` or `loadFailure`
    ///   based on the result of the effect.
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case .load:
            load { success in
                if success {
                    dispatch(.loadSuccess)
                } else {
                    dispatch(.loadFailure)
                }
            }
        }
    }
}

public extension OperationTrackerEffectHandler {
    
    /// Typealias representing the dispatch closure used to send events back to the reducer.
    typealias Dispatch = (Event) -> Void
    
    /// Typealias for the events that can be dispatched by the effect handler.
    typealias Event = OperationTrackerEvent
    
    /// Typealias for the effects that can be handled by the effect handler.
    typealias Effect = OperationTrackerEffect
}
