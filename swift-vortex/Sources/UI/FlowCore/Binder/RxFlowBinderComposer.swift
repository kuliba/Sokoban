//
//  RxFlowBinderComposer.swift
//
//
//  Created by Igor Malyarov on 04.01.2025.
//

import CombineSchedulers
import Foundation

public final class RxFlowBinderComposer {
    
    /// A generic scheduler on which flow operations are performed.
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    /// Initializes a new instance of `RxFlowBinderComposer`.
    ///
    /// - Parameters:
    ///    - scheduler: A `DispatchQueue`-based scheduler for event handling.
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
    ///    - initialState: The initial flow state, defaults to `.init()`.
    ///    - makeContent: A closure that creates a `Content` instance.
    ///    - getNavigation: A function retrieving `Navigation` given a `Select` and `Notify` closure.
    ///    - witnesses: A set of witnesses that define how `Content` emits and receives flow events.
    ///    - Returns: A `Binder` that binds the created `Content` and the composed `Flow`.
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
}
