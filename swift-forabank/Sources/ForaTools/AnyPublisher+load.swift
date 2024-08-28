//
//  AnyPublisher+perform.swift
//
//
//  Created by Igor Malyarov on 28.08.2024.
//

import Combine

/// Extension to handle stateful operations for `AnyPublisher` where the output is `OperationTrackerState`
/// and the failure type is `Never`.
public extension AnyPublisher
where Output == OperationTrackerState,
      Failure == Never {
    
    /// Transforms an `OperationTrackerState` stream into a stream that triggers
    /// operations based on whether the state is terminated and returns a result or a predefined failure value.
    ///
    /// This method observes the `isTerminated` projection of the state. If the state is `.success`,
    /// it triggers the operation and returns the result. If the state is `.failure`, it emits a predefined
    /// failure value. States `.inflight` and `.notStarted` are ignored as they are non-terminal.
    ///
    /// - Parameters:
    ///   - operation: A closure that performs the operation and provides the result through a completion handler.
    ///   - failureValue: A value to emit when the state is `.failure`.
    /// - Returns: An `AnyPublisher` that emits the result on success or the predefined failure value.
    func perform<T>(
        _ operation: @escaping (@escaping (T) -> Void) -> Void,
        failureValue: T
    ) -> AnyPublisher<T, Never> {
        
        self
            .compactMap(\.isTerminated)
            .flatMap {
                
                if $0 == true {
                    return AnyPublisher<T, Never>(operation)
                } else {
                    return Just(failureValue).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    /// Transforms an `OperationTrackerState` stream into a stream that triggers
    /// operations based on whether the state is terminated and returns an optional result.
    ///
    /// This method is similar to the above `perform` method but returns `nil` when the state is `.failure`,
    /// indicating a failure. If the state is `.success`, it triggers the operation.
    ///
    /// - Parameter operation: A closure that performs the operation and provides the result through a completion handler.
    /// - Returns: An `AnyPublisher` that emits the result on success or `nil` on failure.
    func perform<T>(
        _ operation: @escaping (@escaping (T) -> Void) -> Void
    ) -> AnyPublisher<T?, Never> {
        
        return perform(operation, failureValue: nil)
    }
}
