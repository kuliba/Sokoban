//
//  RootViewModelFactory+composeFlow.swift
//  Vortex
//
//  Created by Igor Malyarov on 02.02.2025.
//

import FlowCore

extension RootViewModelFactory {
    
    /// Configures and returns a flow that orchestrates state transitions and navigation events
    /// based on custom behavioral closures.
    ///
    /// The flow starts from an initial state and uses two behaviors:
    /// - The `delayProvider` closure specifies how long to wait before emitting each navigation event.
    /// - The `getNavigation` closure determines the navigation instruction based on the current state.
    ///
    /// This design allows you to control when navigation events occur (e.g., by deferring actions)
    /// and to map state changes to navigation commands in a flexible manner.
    ///
    /// - Parameters:
    ///   - initialState: The initial state from which the flow begins. Defaults to an empty state.
    ///   - delayProvider: A closure that returns a delay value for a given navigation instruction.
    ///   - getNavigation: A closure that maps the current flow state to a navigation instruction.
    /// - Returns: A flow configured to manage state transitions and trigger delayed navigation events.
    @inlinable
    func composeFlow<Select, Navigation>(
        initialState: FlowDomain<Select, Navigation>.State = .init(),
        delayProvider: @escaping (Navigation) -> Delay,
        getNavigation: @escaping FlowDomain<Select, Navigation>.GetNavigation
    ) -> FlowDomain<Select, Navigation>.Flow {
        
        let decoratedGetNavigation = schedulers.interactive.decorateGetNavigation(delayProvider: delayProvider)(getNavigation)
        
        let composer = FlowComposer(
            getNavigation: decoratedGetNavigation,
            scheduler: schedulers.main
        )
        
        return composer.compose(initialState: initialState)
    }
}
