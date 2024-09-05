//
//  OperationTrackerEffectHandler.swift
//
//
//  Created by Igor Malyarov on 27.08.2024.
//

/// A handler responsible for executing effects and dispatching corresponding events
/// based on the results of those effects in the `OperationTracker`.
public final class OperationTrackerEffectHandler {
    
    /// A closure that starts the operation.
    /// The closure accepts a callback that should be invoked with `true` if the operation
    /// succeeds and `false` if it fails.
    private let start: Start
    
    /// Initialises the `OperationTrackerEffectHandler` with a specific start operation.
    /// - Parameter start: A closure that starts the operation and provides the
    /// result via a callback.
    public init(
        start: @escaping Start
    ) {
        self.start = start
    }
    
    /// Typealias representing the start operation, which takes a completion closure
    /// that should be called with a `Bool` indicating the success (`true`) or failure (`false`) of the operation.
    public typealias Start = (@escaping (Bool) -> Void) -> Void
}

public extension OperationTrackerEffectHandler {
    
    /// Handles the given effect and dispatches events based on the outcome of the effect.
    /// - Parameters:
    ///   - effect: The effect to handle, which in this case is typically a `start` operation.
    ///   - dispatch: A closure used to dispatch events such as `succeed` or `fail`
    ///   based on the result of the effect.
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case .start:
            start { success in
                if success {
                    dispatch(.succeed)
                } else {
                    dispatch(.fail)
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
