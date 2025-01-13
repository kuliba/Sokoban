//
//  Publisher+project.swift
//  
//
//  Created by Igor Malyarov on 08.01.2025.
//

import Combine

public extension Publisher where Failure == Never {
    
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

// MARK: - Helpers

private extension FlowState {
    
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
