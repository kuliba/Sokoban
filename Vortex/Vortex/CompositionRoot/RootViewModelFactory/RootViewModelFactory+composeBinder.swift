//
//  RootViewModelFactory+composeBinder.swift
//  Vortex
//
//  Created by Igor Malyarov on 04.01.2025.
//

import FlowCore

extension RootViewModelFactory {
    
    /// Composes a `Binder` using a dynamic content factory and custom navigation logic.
    ///
    /// - Parameters:
    ///   - initialState: The initial state of the flow domain. Defaults to `.init()`.
    ///   - getNavigation: A closure that resolves navigation logic.
    ///   - makeContent: A closure to create the content dynamically.
    ///   - witnesses: Defines how `Content` emits flow events and handles dismisses.
    /// - Returns: A configured `Binder` for the provided parameters.
    @inlinable
    func composeBinder<Content, Select, Navigation>(
        initialState: BinderComposer<Content, Select, Navigation>.Domain.FlowDomain.State = .init(),
        getNavigation: @escaping BinderComposer<Content, Select, Navigation>.GetNavigation,
        makeContent: @escaping () -> Content,
        witnesses: ContentWitnesses<Content, FlowEvent<Select, Never>>
    ) -> Binder<Content, FlowDomain<Select, Navigation>.Flow> {
        
        let composer = RxFlowBinderComposer(scheduler: schedulers.main)
        
        return composer.compose(
            initialState: initialState,
            makeContent: makeContent,
            getNavigation: getNavigation,
            witnesses: witnesses
        )
    }
    
    /// Composes a `Binder` using a dynamic content factory and custom navigation logic with a more restrictive witness setup.
    ///
    /// This overload supports only flow events of type `Select` from the `Content` and still provides
    /// a dismissal action without exposing other flow events directly to the `Content`.
    ///
    /// - Parameters:
    ///   - initialState: The initial state of the flow domain. Defaults to `.init()`.
    ///   - getNavigation: A closure that resolves navigation logic.
    ///   - makeContent: A closure to create the content dynamically.
    ///   - witnesses: Defines how `Content` emits flow events and handles dismisses.
    /// - Returns: A configured `Binder` for the provided parameters.
    @inlinable
    func composeBinder<Content, Select, Navigation>(
        initialState: BinderComposer<Content, Select, Navigation>.Domain.FlowDomain.State = .init(),
        getNavigation: @escaping BinderComposer<Content, Select, Navigation>.GetNavigation,
        makeContent: @escaping () -> Content,
        witnesses: ContentWitnesses<Content, Select>
    ) -> Binder<Content, FlowDomain<Select, Navigation>.Flow> {
        
        let composer = RxFlowBinderComposer(scheduler: schedulers.main)
        
        return composer.compose(
            initialState: initialState,
            makeContent: makeContent,
            getNavigation: getNavigation,
            witnesses: witnesses
        )
    }
}
