//
//  RxFlowBinderComposer.swift
//
//
//  Created by Igor Malyarov on 04.01.2025.
//

import CombineSchedulers
import Foundation

/// A composer that binds a `Content` factory with a `FlowDomain` handling `Select` and `Navigation`,
/// scheduling Flow operations on a `AnySchedulerOf<DispatchQueue>` and coordinating them with content witnesses.
///
/// The `Content` emits Flow events via the `emitting` function in its witnesses and receives only a dismiss
/// action when required, rather than any other Flow events.
public final class RxFlowBinderComposer {
    
    /// A generic scheduler on which flow operations are performed.
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    /// Initializes a new instance of `RxFlowBinderComposer`.
    ///
    /// - Parameters:
    ///   - scheduler: A `DispatchQueue`-based scheduler for event handling.
    public init(
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.scheduler = scheduler
    }
}

public extension RxFlowBinderComposer {
    
    /// Composes a new `Binder` instance.
    ///
    /// - Parameters:
    ///   - initialState: The initial flow state, defaults to `.init()`.
    ///   - makeContent: A closure that creates a `Content` instance.
    ///   - getNavigation: A function retrieving `Navigation` given a `Select` and `Notify` closure.
    ///   - witnesses: Defines how `Content` emits flow events and handles dismisses.
    /// - Returns: A `Binder` that binds the created `Content` and the composed `Flow`.
    func compose<Content, Select, Navigation>(
        initialState: FlowDomain<Select, Navigation>.State = .init(),
        makeContent: @escaping () -> Content,
        getNavigation: @escaping FlowDomain<Select, Navigation>.Composer.GetNavigation,
        witnesses: ContentWitnesses<Content, FlowEvent<Select, Never>>
    ) -> Binder<Content, FlowDomain<Select, Navigation>.Flow> {
        
        let composer = FlowComposer(
            getNavigation: getNavigation,
            scheduler: scheduler
        )
        
        return .init(
            content: makeContent(),
            flow: composer.compose(initialState: initialState),
            bind: witnesses.bind(content:flow:)
        )
    }
    
    /// Composes a new `Binder` instance with a more restrictive witness setup.
    ///
    /// This overload supports only flow events of type `Select` from the `Content` and still provides
    /// a dismissal action without exposing other flow events directly to the `Content`.
    ///
    /// - Parameters:
    ///   - initialState: The initial flow state, defaults to `.init()`.
    ///   - makeContent: A closure that creates a `Content` instance.
    ///   - getNavigation: A function retrieving `Navigation` given a `Select` and `Notify` closure.
    ///   - witnesses: Defines how `Content` emits only `Select` events and handles dismisses.
    /// - Returns: A `Binder` that binds the created `Content` and the composed `Flow`.
    func compose<Content, Select, Navigation>(
        initialState: FlowDomain<Select, Navigation>.State = .init(),
        makeContent: @escaping () -> Content,
        getNavigation: @escaping FlowDomain<Select, Navigation>.Composer.GetNavigation,
        witnesses: ContentWitnesses<Content, Select>
    ) -> Binder<Content, FlowDomain<Select, Navigation>.Flow> {
        
        let composer = FlowComposer(
            getNavigation: getNavigation,
            scheduler: scheduler
        )
        
        return .init(
            content: makeContent(),
            flow: composer.compose(initialState: initialState),
            bind: witnesses.bind(content:flow:)
        )
    }
}
