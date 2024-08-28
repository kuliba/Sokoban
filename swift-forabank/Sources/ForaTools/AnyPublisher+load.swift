//
//  AnyPublisher+load.swift
//
//
//  Created by Igor Malyarov on 28.08.2024.
//

import Combine

/// Extension to handle stateful loading operations.
public extension AnyPublisher
where Output == StatefulLoaderState,
      Failure == Never {
    
    /// Transforms a `StatefulLoaderState` stream into a stream that triggers
    /// loading operations based on the state.
    ///
    /// This method observes state changes and triggers a loading operation
    /// when the state is `.loaded`. If the state is `.failed`, it returns
    /// a predefined failure value. The method also filters out other states.
    ///
    /// - Parameters:
    ///   - load: A closure that performs the loading operation and provides the result.
    ///   - failureValue: A value to return when the state is `.failed`.
    /// - Returns: An `AnyPublisher` that emits the loaded value or a failure value.
    func load<T>(
        _ load: @escaping (@escaping (T) -> Void) -> Void,
        failureValue: T
    ) -> AnyPublisher<T, Never> {
        
        self
            .compactMap { state in
                
                switch state {
                case .failed:     return false
                case .loading:    return nil
                case .loaded:     return true
                case .notStarted: return nil
                }
            }
            .flatMap {
                
                if $0 {
                    return AnyPublisher<T, Never>(load)
                } else {
                    return Just(failureValue).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
}
