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
    
    /// Creates a `Node` holding this flow, with a subscription to its state using a "notify" pattern.
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
    /// - Returns: A `Node` containing this flow instance and a subscription to its state updates.
    ///            The subscription automatically stays alive for the lifetime of the node.
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

// MARK: - NavigationOutcome

/// Represents an outcome of processing a child's navigation state.
/// - `dismiss`: Indicates the child flow should be dismissed.
/// - `select(Select)`: Indicates the child has triggered a selection, passing any relevant data.
enum NavigationOutcome<Select> {
    
    case dismiss
    case select(Select)
}

extension NavigationOutcome: Equatable where Select: Equatable {}

// MARK: - Helpers

extension Publisher where Failure == Never {
    
    /// Projects each `FlowState<Projection>` emitted by the publisher into a `FlowEvent<Select, Never>`,
    /// based on a custom `transform` logic.
    ///
    /// - Parameter transform: A closure mapping `Projection` (the navigation data) to an optional `NavigationOutcome<Select>`.
    ///   If `nil` is returned, no `.select` or `.dismiss` event is produced, falling back to `.isLoading(false)`.
    /// - Returns: An `AnyPublisher<FlowEvent<Select, Never>, Never>` that emits loading states, dismissal, or selection events.
    func project<Projection, Select>(
        _ transform: @escaping (Projection) -> NavigationOutcome<Select>?
    ) -> AnyPublisher<FlowEvent<Select, Never>, Never>
    where Output == FlowState<Projection> {
        
        map { $0.project(transform) }
            .eraseToAnyPublisher()
    }
}

extension FlowState {
    
    /// Transforms a `FlowState<Navigation>` into a `FlowEvent<Select, Never>` by:
    /// 1. Sending `.isLoading(true)` if `isLoading == true`.
    /// 2. Checking whether `navigation` can map to `.dismiss` or `.select(...)` via `transform`.
    /// 3. Falling back to `.isLoading(false)` if no loading or selection/dismissal applies.
    ///
    /// - Parameter transform: A closure mapping `Navigation` to an optional `NavigationOutcome<Select>`.
    ///   - `.dismiss` -> Produces `.dismiss` event.
    ///   - `.select(...)` -> Produces `.select(...)` event.
    ///   - `nil` -> Produces `.isLoading(false)` if not loading.
    ///
    /// - Returns: A `FlowEvent<Select, Never>` representing the state of the child flow.
    func project<Select>(
        _ transform: @escaping (Navigation) -> NavigationOutcome<Select>?
    ) -> FlowEvent<Select, Never> {
        
        // If the flow is loading, always send a loading event.
        if isLoading {
            
            return .isLoading(true)
        }
        
        // Map the navigation to a possible outcome, if navigation is present.
        if let outcome = navigation.flatMap(transform) {
            
            switch outcome {
            case .dismiss:
                return .dismiss
                
            case let .select(select):
                return .select(select)
            }
        }
        
        // If we reached here, there's no loading and no special outcome -> not loading.
        return .isLoading(false)
    }
}
