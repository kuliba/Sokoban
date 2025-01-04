//
//  RxFlowBinderComposer.swift
//
//
//  Created by Igor Malyarov on 04.01.2025.
//

import CombineSchedulers
import Foundation

/// A composer that binds a `Content` factory with a `FlowDomain` handling `Select` and `Navigation`,
/// scheduled by a `AnySchedulerOf<DispatchQueue>` and coordinated by content witnesses.
public final class RxFlowBinderComposer<Content, Select, Navigation> {
    
    /// A closure creating the `Content`.
    private let makeContent: () -> Content
    
    /// A function retrieving the current `Navigation` for a given `Select`.
    private let getNavigation: FlowDomain.Composer.GetNavigation
    
    /// A generic scheduler on which flow operations are performed.
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    /// Witnesses that handle binding between `Content` and `FlowEvent`.
    private let witnesses: Witnesses
    
    /// Initializes a new instance of `RxFlowBinderComposer`.
    ///
    /// - Parameters:
    ///    - makeContent: A closure that creates a `Content` instance.
    ///    - getNavigation: A function retrieving `Navigation` given a `Select`.
    ///    - witnesses: A set of witnesses that define how `Content` emits and receives flow events.
    ///    - scheduler: A `DispatchQueue`-based scheduler for event handling.
    public init(
        makeContent: @escaping () -> Content,
        getNavigation: @escaping FlowDomain.Composer.GetNavigation,
        witnesses: Witnesses,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.makeContent = makeContent
        self.getNavigation = getNavigation
        self.scheduler = scheduler
        self.witnesses = witnesses
    }
    
    /// A typealias grouping `Content` and `FlowEvent<Select, Never>`.
    public typealias Witnesses = ContentWitnesses<Content, FlowEvent<Select, Never>>
}

public extension RxFlowBinderComposer {
    
    /// Composes a new `Binder` instance from the provided `initialState`.
    ///
    ///    - Parameter initialState: The initial flow state, defaults to `.init()`.
    ///    - Returns: A `Binder` that binds the created `Content` and the composed `Flow`.
    func compose(
        initialState: FlowDomain.State = .init()
    ) -> Binder {
        
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
    
    /// A typealias for a `Binder` associating the `Content` with a `Flow`.
    typealias Binder = FlowCore.Binder<Content, Flow>
    
    /// A typealias representing the `Flow` from `FlowDomain`.
    typealias Flow = FlowDomain.Flow
    
    /// A typealias referencing the domain that handles `Select` and `Navigation`.
    typealias FlowDomain = FlowCore.FlowDomain<Select, Navigation>
}
