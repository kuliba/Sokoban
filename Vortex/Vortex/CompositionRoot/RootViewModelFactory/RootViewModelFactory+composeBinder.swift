//
//  RootViewModelFactory+composeBinder.swift
//  Vortex
//
//  Created by Igor Malyarov on 04.01.2025.
//

import FlowCore

extension RootViewModelFactory {
    
    /// Composes a `Binder` that binds a given `Content` instance with a `Flow` using custom navigation behavior.
    ///
    /// This method sets up a `Binder` by combining:
    /// - An initial state for the flow.
    /// - A delay provider that specifies how long to wait before triggering a navigation event.
    /// - A navigation resolver that determines navigation instructions based on `Select` events.
    ///
    /// - Parameters:
    ///   - content: The content instance to be bound.
    ///   - initialState: The initial state of the flow domain. Defaults to `.init()`.
    ///   - delayProvider: A closure that returns a delay value for a given navigation event, enabling smooth UI transitions.
    ///   - getNavigation: A closure that resolves navigation logic based on `Select` events.
    ///   - witnesses: Defines how the `Content` emits `FlowEvent<Select, Never>` events and handles dismiss actions.
    /// - Returns: A configured `Binder` instance that binds the provided `Content` with the corresponding `Flow`.
    @inlinable
    func composeBinder<Content, Select, Navigation>(
        content: Content,
        initialState: FlowDomain<Select, Navigation>.State = .init(),
        delayProvider: @escaping (Navigation) -> Delay,
        getNavigation: @escaping FlowDomain<Select, Navigation>.GetNavigation,
        witnesses: ContentWitnesses<Content, FlowEvent<Select, Never>>
    ) -> Binder<Content, FlowDomain<Select, Navigation>.Flow> {
        
        let decoratedGetNavigation = schedulers.interactive.decorateGetNavigation(delayProvider: delayProvider)(getNavigation)
        
        let flow = composeFlow(
            initialState: initialState,
            delayProvider: delayProvider,
            getNavigation: decoratedGetNavigation
        )
        
        return witnesses.composeBinder(content: content, flow: flow)
    }
    
    /// Composes a `Binder` that binds a given `Content` instance with a `Flow` using a more restricted event mapping.
    ///
    /// This overload is intended for scenarios where `Content` emits only `Select` events.
    /// It wraps these events into a `FlowEvent.select` case, providing a dismissal action without exposing other event types.
    ///
    /// - Parameters:
    ///   - content: The content instance to be bound.
    ///   - initialState: The initial state of the flow domain. Defaults to `.init()`.
    ///   - delayProvider: A closure that returns a delay value for a given navigation event, ensuring smooth UI transitions.
    ///   - getNavigation: A closure that resolves navigation logic based on `Select` events.
    ///   - witnesses: Defines how the `Content` emits `Select` events and handles dismiss actions.
    /// - Returns: A configured `Binder` instance that binds the provided `Content` with the corresponding `Flow`.
    ///
    /// - Warning: This overload only supports flow events of type `Select` from the `Content` and does not expose additional flow events.
    @inlinable
    func composeBinder<Content, Select, Navigation>(
        content: Content,
        initialState: FlowDomain<Select, Navigation>.State = .init(),
        delayProvider: @escaping (Navigation) -> Delay,
        getNavigation: @escaping FlowDomain<Select, Navigation>.GetNavigation,
        selectWitnesses witnesses: ContentWitnesses<Content, Select>
    ) -> Binder<Content, FlowDomain<Select, Navigation>.Flow> {
        
        return composeBinder(
            content: content,
            initialState: initialState,
            delayProvider: delayProvider,
            getNavigation: getNavigation,
            witnesses: witnesses.wrappingAsFlowEvent()
        )
    }
}

private extension ContentWitnesses {
    
    /// Converts a `ContentWitnesses<Content, Select>` to `ContentWitnesses<Content, FlowEvent<Select, Never>>`.
    ///
    /// This function wraps `Select` events into the `FlowEvent.select` case, allowing components
    /// that expect a broader event type to work with a simpler event definition. The original dismissing behavior is preserved.
    ///
    /// - Returns: A new `ContentWitnesses` instance with `FlowEvent<Select, Never>` as the event type.
    func wrappingAsFlowEvent() -> ContentWitnesses<Content, FlowEvent<Select, Never>> {
        
        return .init(
            emitting: { emitting($0).map(FlowEvent.select) },
            dismissing: dismissing
        )
    }
}
