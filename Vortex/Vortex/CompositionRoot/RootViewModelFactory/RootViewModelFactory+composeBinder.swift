//
//  RootViewModelFactory+composeBinder.swift
//  Vortex
//
//  Created by Igor Malyarov on 04.01.2025.
//

import FlowCore

extension RootViewModelFactory {
    
    // TODO: add docs
    // TODO: extract to separate file
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
    
    /// Composes a `Binder` using a dynamic content factory and custom navigation logic.
    ///
    /// This method sets up a `Binder` that binds a dynamically created `Content` instance with a `Flow`,
    /// resolving navigation logic and handling delays for transitions.
    ///
    /// - Parameters:
    ///   - initialState: The initial state of the flow domain. Defaults to `.init()`.
    ///   - delayProvider: A closure that provides a delay for a given navigation. Delays allow smooth UI transitions.
    ///   - getNavigation: A closure that resolves navigation logic based on `Select` events.
    ///   - makeContent: A closure to dynamically create a `Content` instance.
    ///   - witnesses: Defines how `Content` emits `FlowEvent<Select, Never>` events and handles dismiss actions.
    /// - Returns: A configured `Binder` instance for the provided parameters that binds `Content` with the `Flow`.
    @inlinable
    func composeBinder<Content, Select, Navigation>(
        makeContent: @escaping () -> Content,
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
        
        return witnesses.composeBinder(content: makeContent(), flow: flow)
    }
    
    /// Composes a `Binder` using a content instance and custom navigation logic.
    ///
    /// This method sets up a `Binder` that binds a dynamically created `Content` instance with a `Flow`,
    /// resolving navigation logic and handling delays for transitions.
    ///
    /// - Parameters:
    ///   - initialState: The initial state of the flow domain. Defaults to `.init()`.
    ///   - delayProvider: A closure that provides a delay for a given navigation. Delays allow smooth UI transitions.
    ///   - getNavigation: A closure that resolves navigation logic based on `Select` events.
    ///   - content: A `Content` instance.
    ///   - witnesses: Defines how `Content` emits `FlowEvent<Select, Never>` events and handles dismiss actions.
    /// - Returns: A configured `Binder` instance for the provided parameters that binds `Content` with the `Flow`.
    @inlinable
    func composeBinder<Content, Select, Navigation>(
        content: Content,
        initialState: FlowDomain<Select, Navigation>.State = .init(),
        delayProvider: @escaping (Navigation) -> Delay,
        getNavigation: @escaping FlowDomain<Select, Navigation>.GetNavigation,
        witnesses: ContentWitnesses<Content, FlowEvent<Select, Never>>
    ) -> Binder<Content, FlowDomain<Select, Navigation>.Flow> {
        
        return composeBinder(
            makeContent: { content },
            initialState: initialState,
            delayProvider: delayProvider,
            getNavigation: getNavigation,
            witnesses: witnesses
        )
    }
    
    /// Composes a `Binder` using a dynamic content factory and custom navigation logic with a more restrictive witness setup.
    ///
    /// This method is designed for cases where `Content` only emits `Select` events and does not interact with other event types.
    ///
    /// - Parameters:
    ///   - initialState: The initial state of the flow domain. Defaults to `.init()`.
    ///   - delayProvider: A closure that provides a delay for a given navigation. Delays allow smooth UI transitions.
    ///   - getNavigation: A closure that resolves navigation logic based on `Select` events.
    ///   - makeContent: A closure to dynamically create a `Content` instance.
    ///   - witnesses: Defines how `Content` emits `Select` flow events and handles dismisses.
    /// - Returns: A configured `Binder` instance for the provided parameters that binds `Content` with the `Flow`.
    ///
    /// - Warning: This overload supports only flow events of type `Select` from the `Content` and still provides
    /// a dismissal action without exposing other flow events directly to the `Content`.
    @inlinable
    func composeBinder<Content, Select, Navigation>(
        makeContent: @escaping () -> Content,
        initialState: FlowDomain<Select, Navigation>.State = .init(),
        delayProvider: @escaping (Navigation) -> Delay,
        getNavigation: @escaping FlowDomain<Select, Navigation>.GetNavigation,
        witnesses: ContentWitnesses<Content, Select>
    ) -> Binder<Content, FlowDomain<Select, Navigation>.Flow> {
        
        return composeBinder(
            makeContent: makeContent,
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
    /// This function wraps `Select` events into the `FlowEvent.select` case, allowing `ContentWitnesses`
    /// to interact with components expecting a broader event type. The original dismissing behavior is
    /// preserved without modification.
    ///
    /// - Returns: A new `ContentWitnesses` instance with `FlowEvent<Select, Never>` as the event type.
    func wrappingAsFlowEvent() -> ContentWitnesses<Content, FlowEvent<Select, Never>> {
        
        return .init(
            emitting: { emitting($0).map(FlowEvent.select) },
            dismissing: dismissing
        )
    }
}
