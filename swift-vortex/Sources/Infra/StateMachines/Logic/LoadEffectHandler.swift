//
//  LoadEffectHandler.swift
//
//
//  Created by Igor Malyarov on 19.02.2025.
//

/// Handles the side effects of the loading process.
public final class LoadEffectHandler<Success, Failure: Error> {
    
    private let load: Load
    
    /// Initializes a new instance of `LoadEffectHandler`.
    ///
    /// - Parameter load: A closure that performs the load action.
    public init(load: @escaping Load) {
        
        self.load = load
    }
    
    /// Completion type alias for the load process.
    public typealias LoadCompletion = (Result<Success, Failure>) -> Void
    /// Type alias for the load closure.
    public typealias Load = (@escaping LoadCompletion) -> Void
}

public extension LoadEffectHandler {
    
    /// Handles the specified effect.
    ///
    /// - Parameters:
    ///   - effect: The effect to handle.
    ///   - dispatch: A closure to dispatch resulting events.
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

public extension LoadEffectHandler {
    
    /// Type alias for the dispatch function.
    typealias Dispatch = (Event) -> Void
    /// Type alias for the events handled by `LoadEffectHandler`.
    typealias Event = LoadEvent<Success, Failure>
    /// Type alias for the effects handled by `LoadEffectHandler`.
    typealias Effect = LoadEffect
}
