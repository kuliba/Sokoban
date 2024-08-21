//
//  Binder.swift
//
//
//  Created by Igor Malyarov on 19.08.2024.
//

import Combine

/// A generic class that binds a `Content` instance with a `Flow` instance, managing their lifecycle
/// through a cancellable binding. This class is particularly useful in reactive programming scenarios,
/// where the binding between content and flow may involve asynchronous or event-driven operations.
public final class Binder<Content, Flow> {

    /// The content to be bound with the flow. This is an immutable property.
    public let content: Content

    /// The flow to be bound with the content. This is an immutable property.
    public let flow: Flow

    /// A cancellable object that manages the lifecycle of the binding between `content` and `flow`.
    /// This property is private, encapsulating the binding logic and ensuring that the cancellation
    /// is handled internally.
    private let cancellable: AnyCancellable

    /// Initialises a new `Binder` instance, binding the provided `content` and `flow` using the given
    /// `bind` closure. The `bind` closure is expected to return an `AnyCancellable` that manages the
    /// lifecycle of the binding, ensuring that resources are properly released when the binding is no
    /// longer needed.
    ///
    /// - Parameters:
    ///   - content: The content to be bound with the flow.
    ///   - flow: The flow to be bound with the content.
    ///   - bind: A closure that takes `content` and `flow` as arguments and returns an `AnyCancellable`
    ///           that manages the binding's lifecycle.
    ///
    /// - Returns: A new instance of `Binder` that encapsulates the binding between `content` and `flow`.
    public init(
        content: Content,
        flow: Flow,
        bind: (Content, Flow) -> AnyCancellable
    ) {
        self.content = content
        self.flow = flow
        self.cancellable = bind(content, flow)
    }
}
