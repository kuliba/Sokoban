//
//  ContentWitnesses.swift
//
//
//  Created by Igor Malyarov on 10.11.2024.
//

import Combine

/// A container that holds emitting and dismissing functions for content of type `Content`.
///
/// The `emitting` function exposes a publisher of `Select` values emitted by the `Content`.
/// The `dismissing` function provides a closure that can be invoked to dismiss or unwind the `Content`.
/// Note that the `Content` does not receive Flow events; it only receives a dismiss action when required.
public struct ContentWitnesses<Content, Select> {
    
    /// A function that takes `Content` and returns a publisher emitting `Select` values.
    public let emitting: Emitting
    
    /// A function that takes `Content` and returns an action (closure) to be executed.
    public let dismissing: Dismissing
    
    /// Initializes a new `ContentWitnesses` with the provided emitting and dismissing functions.
    ///
    /// - Parameters:
    ///   - emitting: A function that takes `Content` and returns a publisher emitting `Select` values.
    ///   - dismissing: A function that takes `Content` and returns an action (closure) to be executed.
    public init(
        emitting: @escaping Emitting,
        dismissing: @escaping Dismissing
    ) {
        self.emitting = emitting
        self.dismissing = dismissing
    }
}

public extension ContentWitnesses {
    
    /// A typealias for the emitting function.
    ///
    /// The function takes a `Content` and returns a publisher emitting `Select` values.
    typealias Emitting = (Content) -> AnyPublisher<Select, Never>
    
    /// A typealias for the dismissing function.
    ///
    /// The function takes a `Content` and returns an action (closure) that can be executed.
    typealias Dismissing = (Content) -> () -> Void
}

public extension ContentWitnesses {
    
    /// Merges the current `ContentWitnesses` with another one.
    ///
    /// The resulting `ContentWitnesses` will combine the emitting and dismissing functions of both instances.
    ///
    /// - Parameter other: Another `ContentWitnesses` to merge with.
    mutating func merge(with other: Self) {
        
        let emitting = emitting
        let dismissing = dismissing
        
        self = .init(
            emitting: { content in
                emitting(content)
                    .merge(with: other.emitting(content))
                    .eraseToAnyPublisher()
            },
            dismissing: { content in
                return {
                    dismissing(content)()
                    other.dismissing(content)()
                }
            }
        )
    }
    
    /// Creates a new `ContentWitnesses` by merging the current instance with another.
    ///
    /// The resulting `ContentWitnesses` will combine the emitting and dismissing functions of both instances.
    ///
    /// - Parameter other: Another `ContentWitnesses` to merge with.
    /// - Returns: A new `ContentWitnesses` instance where the `emitting` functions are merged into a single publisher
    ///            and the `dismissing` functions are executed sequentially.
    func merging(with other: Self) -> Self {
        
        let emitting = emitting
        let dismissing = dismissing
        
        return .init(
            emitting: { content in
                emitting(content)
                    .merge(with: other.emitting(content))
                    .eraseToAnyPublisher()
            },
            dismissing: { content in
                return {
                    dismissing(content)()
                    other.dismissing(content)()
                }
            }
        )
    }}

public extension ContentWitnesses {
    
    /// Initializes a new `ContentWitnesses` with the provided emitting and dismissing functions.
    ///
    /// This initializer allows the emitting function to use a custom publisher type.
    ///
    /// - Parameters:
    ///   - emitting: A function that takes `Content` and returns a publisher emitting `Select` values.
    ///   - dismissing: A function that takes `Content` and returns an action (closure) to be executed.
    init<P: Publisher>(
        emitting: @escaping (Content) -> P,
        dismissing: @escaping Dismissing
    ) where P.Output == Select, P.Failure == Never {
        
        self.init(
            emitting: { emitting($0).eraseToAnyPublisher() },
            dismissing: dismissing
        )
    }
}
