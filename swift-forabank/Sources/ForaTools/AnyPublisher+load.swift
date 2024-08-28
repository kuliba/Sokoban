//
//  AnyPublisher+load.swift
//
//
//  Created by Igor Malyarov on 28.08.2024.
//

import Combine

/// Extension to handle stateful loading operations for `AnyPublisher` where the output is `StatefulLoaderState`
/// and the failure type is `Never`.
public extension AnyPublisher
where Output == StatefulLoaderState,
      Failure == Never {
    
    /// Transforms a `StatefulLoaderState` stream into a stream that triggers
    /// loading operations based on the state and returns a result or a predefined failure value.
    ///
    /// This method observes state changes and triggers a loading operation when the state is `.loaded`.
    /// If the state is `.failed`, it emits a predefined failure value. States `.loading` and `.notStarted`
    /// are filtered out and do not trigger any actions.
    ///
    /// - Parameters:
    ///   - block: A closure that performs the loading operation and provides the result through a completion handler.
    ///   - failureValue: A value to emit when the state is `.failed`.
    /// - Returns: An `AnyPublisher` that emits the loaded value on success or the predefined failure value.
    func load<T>(
        _ block: @escaping (@escaping (T) -> Void) -> Void,
        failureValue: T
    ) -> AnyPublisher<T, Never> {
        
        self
            .compactMap(\.isTerminated)
            .flatMap {
                
                if $0 {
                    return AnyPublisher<T, Never>(block)
                } else {
                    return Just(failureValue).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    /// Transforms a `StatefulLoaderState` stream into a stream that triggers
    /// loading operations based on the state and returns an optional result.
    ///
    /// This method is similar to the above `load` method but returns `nil` when the state is `.failed`,
    /// indicating a failure. If the state is `.loaded`, it triggers the loading operation.
    ///
    /// - Parameter block: A closure that performs the loading operation and provides the result through a completion handler.
    /// - Returns: An `AnyPublisher` that emits the loaded value on success or `nil` on failure.
    func load<T>(
        _ block: @escaping (@escaping (T) -> Void) -> Void
    ) -> AnyPublisher<T?, Never> {
        
        return load(block, failureValue: nil)
    }
}
