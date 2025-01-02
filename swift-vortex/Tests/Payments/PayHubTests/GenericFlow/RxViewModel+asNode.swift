//
//  RxViewModel+asNode.swift
//
//
//  Created by Igor Malyarov on 01.01.2025.
//

import Combine
import PayHub
import RxViewModel

extension RxViewModel {
    
    /// Creates a `Node` holding this flow, with a subscription to its state using the `notify` pattern.
    ///
    /// - Parameters:
    ///   - transform: A closure that maps `Navigation` into `ParentSelect`.
    ///   - notify: A callback for forwarding the transformed `FlowEvent` to the parent.
    ///
    /// - Returns: A `Node` containing this flow and a subscription to its state.
    func asNode<Select, Navigation, ParentSelect>(
        transform: @escaping (Navigation) -> NavigationOutcome<ParentSelect>?,
        notify: @escaping (FlowEvent<ParentSelect, Never>) -> Void
    ) -> Node<RxViewModel>
    where State == FlowState<Navigation>,
          Event == FlowEvent<Select, Navigation>,
          Effect == FlowEffect<Select> {
              
              let cancellable = $state
                  .dropFirst()
                  .project(transform)
                  .sink(receiveValue: notify)
              
              return Node(model: self, cancellable: cancellable)
          }
}

enum NavigationOutcome<Select> {
    
    case dismiss
    case select(Select)
}

extension NavigationOutcome: Equatable where Select: Equatable {}
