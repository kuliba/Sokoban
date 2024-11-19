//
//  ContentWitnesses.swift
//
//
//  Created by Igor Malyarov on 10.11.2024.
//

import Combine

import Combine

/// A container that holds emitting and receiving functions for content of type `Content`.
///
/// The `emitting` function produces a publisher of `Select` values given a `Content`.
/// The `receiving` function produces an action (closure) to be performed given a `Content`.
public struct ContentWitnesses<Content, Select> {
    
    /// A function that takes `Content` and returns a publisher emitting `Select` values.
    public let emitting: Emitting
    
    /// A function that takes `Content` and returns an action (closure) to be executed.
    public let receiving: Receiving
    
    /// Initializes a new `ContentWitnesses` with the provided emitting and receiving functions.
    ///
    /// - Parameters:
    ///   - emitting: A function that takes `Content` and returns a publisher emitting `Select` values.
    ///   - receiving: A function that takes `Content` and returns an action (closure) to be executed.
    public init(
        emitting: @escaping Emitting,
        receiving: @escaping Receiving
    ) {
        self.emitting = emitting
        self.receiving = receiving
    }
}

public extension ContentWitnesses {
    
    /// A typealias for the emitting function.
    ///
    /// The function takes a `Content` and returns a publisher emitting `Select` values.
    typealias Emitting = (Content) -> AnyPublisher<Select, Never>
    
    /// A typealias for the receiving function.
    ///
    /// The function takes a `Content` and returns an action (closure) that can be executed.
    typealias Receiving = (Content) -> () -> Void
}

public extension ContentWitnesses {
    
    /// Merges the current `ContentWitnesses` with another one.
    ///
    /// The resulting `ContentWitnesses` will combine the emitting and receiving functions of both instances.
    ///
    /// - Parameter other: Another `ContentWitnesses` to merge with.
    mutating func merge(with other: Self) {
        
        let emitting = emitting
        let receiving = receiving
        
        self = .init(
            emitting: { content in
                emitting(content)
                    .merge(with: other.emitting(content))
                    .eraseToAnyPublisher()
            },
            receiving: { content in
                return {
                    receiving(content)()
                    other.receiving(content)()
                }
            }
        )
    }
}
