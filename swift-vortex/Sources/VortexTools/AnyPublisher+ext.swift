//
//  AnyPublisher+ext.swift
//
//
//  Created by Igor Malyarov on 28.08.2024.
//

import Combine

public extension AnyPublisher where Failure == Error {
    
    /// Initialises an `AnyPublisher` that wraps an asynchronous block that returns a `Result`.
    ///
    /// This initialiser allows you to create an `AnyPublisher` from a closure
    /// that performs an asynchronous operation and returns a `Result` indicating
    /// either success or failure.
    ///
    /// - Parameter block: A closure that performs an asynchronous operation and
    ///   invokes the provided callback with a `Result<Output, Failure>`, where
    ///   `Output` is the type of the successful result and `Failure` is the error type.
    init(
        _ block: @escaping(@escaping (Result<Output, Failure>) -> Void) -> Void
    ) {
        self = Deferred {
            Future(block)
        }
        .eraseToAnyPublisher()
    }
}

/// Extension to add convenience methods for `AnyPublisher`
public extension AnyPublisher where Failure == Never {
    
    /// Initialises an `AnyPublisher` that wraps an asynchronous block.
    ///
    /// This initialiser allows you to create an `AnyPublisher` from a closure
    /// that performs an asynchronous operation and invokes a callback with the result.
    ///
    /// - Parameter block: A closure that performs an asynchronous operation and
    ///   invokes the provided callback with the output.
    init(
        _ block: @escaping(@escaping (Output) -> Void) -> Void
    ) {
        self = Deferred {
            
            Future<Output, Never> { promise in
                
                block { promise(.success($0)) }
            }
        }
        .eraseToAnyPublisher()
    }
}
