//
//  Node.swift
//  Vortex
//
//  Created by Igor Malyarov on 31.07.2024.
//

import Combine

/// A generic struct representing a node that binds a `Model` instance with a set of cancellable objects.
/// This struct is useful in scenarios where a model's lifecycle is tied to cancellable operations.
public struct Node<Model> {
    
    /// The model instance associated with this node.
    public let model: Model
    
    /// A set of cancellable objects that manage the lifecycle of the model's associated operations.
    /// This property is private to ensure lifecycle management is encapsulated within the node.
    private let cancellables: Set<AnyCancellable>
    
    /// Initializes a `Node` instance with a model and a set of cancellable objects.
    ///
    /// - Parameters:
    ///   - model: The model instance associated with this node.
    ///   - cancellables: A set of `AnyCancellable` objects that manage the model's lifecycle.
    public init(
        model: Model,
        cancellables: Set<AnyCancellable>
    ) {
        self.model = model
        self.cancellables = cancellables
    }
    
    /// Initializes a `Node` instance with a model and a single cancellable object.
    ///
    /// - Parameters:
    ///   - model: The model instance associated with this node.
    ///   - cancellable: A single `AnyCancellable` object that manages the model's lifecycle.
    public init(
        model: Model,
        cancellable: AnyCancellable
    ) {
        self.init(model: model, cancellables: [cancellable])
    }
}

// MARK: - Conformance

/// Conforms to `Equatable` when the `Model` type is also `Equatable`.
extension Node: Equatable where Model: Equatable {}
