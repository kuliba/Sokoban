//
//  Binder+asNode.swift
//
//
//  Created by Igor Malyarov on 02.01.2025.
//

import RxViewModel

public extension Binder {
    
    /// Creates a `Node` holding this binder, with a subscription to its flow state using a "notify" pattern.
    ///
    /// This method wires the child flow's state updates into a `FlowEvent<ParentSelect, Never>` stream,
    /// allowing a parent flow or other observers to receive:
    /// - Loading signals (`.isLoading(true)` / `.isLoading(false)`)
    /// - Navigation signals translated into `.select(...)`
    /// - Dismissal signals (`.dismiss`) when the child flow finishes or requests closure
    ///
    /// - Parameters:
    ///   - transform: A closure mapping the child's `Navigation` to a `NavigationOutcome<ParentSelect>` (either `.dismiss` or `.select(...)`).
    ///                Return `nil` if no special event should be emitted for a given navigation state.
    ///   - notify: A callback that forwards the resulting `FlowEvent<ParentSelect, Never>` to the parent.
    ///
    /// - Returns: A `Node` containing this binder instance and a subscription to its flow state updates.
    ///            The subscription automatically stays alive for the lifetime of the node.
    func asNode<Select, Navigation, ParentSelect>(
        transform: @escaping (Navigation) -> NavigationOutcome<ParentSelect>?,
        notify: @escaping (FlowEvent<ParentSelect, Never>) -> Void
    ) -> Node<Binder>
    where Flow == RxViewModel<FlowState<Navigation>, FlowEvent<Select, Navigation>, FlowEffect<Select>> {
        
        let cancellable = flow.$state
            .dropFirst()
            .project(transform)
            .sink(receiveValue: notify)
        
        return Node(model: self, cancellable: cancellable)
    }
}
