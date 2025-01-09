//
//  RootViewModelFactory+compose.swift
//  Vortex
//
//  Created by Igor Malyarov on 21.11.2024.
//

import Foundation
import PayHub
import PayHubUI
import RxViewModel

extension RootViewModelFactory {
    
    /// Composes a `Binder` using a dynamic content factory and custom navigation logic.
    ///
    /// - Parameters:
    ///   - initialState: The initial state of the flow domain. Defaults to `.init()`.
    ///   - getNavigation: A closure that resolves navigation logic.
    ///   - makeContent: A closure to create the content dynamically.
    ///   - witnesses: Supporting witnesses required by the `BinderComposer`.
    /// - Returns: A configured `Binder` for the provided parameters.
    @inlinable
    func composeBinder<Content, Select, Navigation>(
        initialState: BinderComposer<Content, Select, Navigation>.Domain.FlowDomain.State = .init(),
        getNavigation: @escaping BinderComposer<Content, Select, Navigation>.GetNavigation,
        makeContent: @escaping () -> Content,
        witnesses: BinderComposer<Content, Select, Navigation>.Witnesses
    ) -> Binder<Content, RxViewModel<Vortex.FlowState<Navigation>, Vortex.FlowEvent<Select, Navigation>, Vortex.FlowEffect<Select>>> {
        
        let composer = BinderComposer(
            getNavigation: getNavigation,
            makeContent: makeContent,
            schedulers: schedulers,
            witnesses: witnesses
        )
        
        return composer.compose(initialState: initialState)
    }

    /// Composes a `Binder` using static content and custom navigation logic.
    ///
    /// - Parameters:
    ///   - initialState: The initial state of the flow domain. Defaults to `.init()`.
    ///   - getNavigation: A closure that resolves navigation logic.
    ///   - content: Static content to be used by the binder.
    ///   - witnesses: Supporting witnesses required by the `BinderComposer`.
    /// - Returns: A configured `Binder` for the provided parameters.
    @inlinable
    func composeBinder<Content, Select, Navigation>(
        initialState: BinderComposer<Content, Select, Navigation>.Domain.FlowDomain.State = .init(),
        getNavigation: @escaping BinderComposer<Content, Select, Navigation>.GetNavigation,
        content: Content,
        witnesses: BinderComposer<Content, Select, Navigation>.Witnesses
    ) -> Binder<Content, RxViewModel<Vortex.FlowState<Navigation>, Vortex.FlowEvent<Select, Navigation>, Vortex.FlowEffect<Select>>> {
        
        return composeBinder(
            initialState: initialState,
            getNavigation: getNavigation,
            makeContent: { content },
            witnesses: witnesses
        )
    }
}

extension RootViewModelFactory {
    
    typealias Delay = DispatchQueue.SchedulerTimeType.Stride
    
    /// Composes a `Binder` using a dynamic content factory and custom navigation logic.
    ///
    /// - Parameters:
    ///   - initialState: The initial state of the flow domain. Defaults to `.init()`.
    ///   - delay: The delay used to handle SwiftUI quirks (e.g., writing `nil` to navigation destination).
    ///   - getNavigation: A closure that resolves navigation logic.
    ///   - makeContent: A closure to create the content dynamically.
    ///   - witnesses: Supporting witnesses required by the `BinderComposer`.
    /// - Returns: A configured `Binder` for the provided parameters.
    @inlinable
    @available(*, deprecated, message: "Control delays in `getNavigation`.")
    func compose<Content, Select, Navigation>(
        initialState: BinderComposer<Content, Select, Navigation>.Domain.FlowDomain.State = .init(),
        delay: Delay? = nil,
        getNavigation: @escaping BinderComposer<Content, Select, Navigation>.GetNavigation,
        makeContent: @escaping () -> Content,
        witnesses: BinderComposer<Content, Select, Navigation>.Witnesses
    ) -> Binder<Content, RxViewModel<Vortex.FlowState<Navigation>, Vortex.FlowEvent<Select, Navigation>, Vortex.FlowEffect<Select>>> {
        
        let composer = BinderComposer(
            delay: delay ?? settings.delay,
            getNavigation: getNavigation,
            makeContent: makeContent,
            schedulers: schedulers,
            witnesses: witnesses
        )
        
        return composer.compose(initialState: initialState)
    }

    /// Composes a `Binder` using static content and custom navigation logic.
    ///
    /// - Parameters:
    ///   - initialState: The initial state of the flow domain. Defaults to `.init()`.
    ///   - delay: The delay used to handle SwiftUI quirks (e.g., writing `nil` to navigation destination).
    ///   - getNavigation: A closure that resolves navigation logic.
    ///   - content: Static content to be used by the binder.
    ///   - witnesses: Supporting witnesses required by the `BinderComposer`.
    /// - Returns: A configured `Binder` for the provided parameters.
    @inlinable
    @available(*, deprecated, message: "Control delays in `getNavigation`.")
    func compose<Content, Select, Navigation>(
        initialState: BinderComposer<Content, Select, Navigation>.Domain.FlowDomain.State = .init(),
        delay: Delay? = nil,
        getNavigation: @escaping BinderComposer<Content, Select, Navigation>.GetNavigation,
        content: Content,
        witnesses: BinderComposer<Content, Select, Navigation>.Witnesses
    ) -> Binder<Content, RxViewModel<Vortex.FlowState<Navigation>, Vortex.FlowEvent<Select, Navigation>, Vortex.FlowEffect<Select>>> {
        
        return compose(
            initialState: initialState, 
            delay: delay,
            getNavigation: getNavigation,
            makeContent: { content },
            witnesses: witnesses
        )
    }
}
