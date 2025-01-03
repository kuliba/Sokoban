//
//  BinderComposer.swift
//
//
//  Created by Igor Malyarov on 10.11.2024.
//

import Foundation

public final class BinderComposer<Content, Select, Navigation> {
    
    @available(*, deprecated, message: "Control delays in `getNavigation`.")
    private let delay: Delay?
    
    private let getNavigation: GetNavigation
    private let makeContent: MakeContent
    private let schedulers: Schedulers
    private let witnesses: Witnesses
    
    /// `delay` is needed to handle SwiftUI writing nil to navigation destination after new destination is already set.
    public init(
        getNavigation: @escaping GetNavigation,
        makeContent: @escaping MakeContent,
        schedulers: Schedulers = .init(),
        witnesses: Witnesses
    ) {
        self.delay = nil
        self.getNavigation = getNavigation
        self.makeContent = makeContent
        self.schedulers = schedulers
        self.witnesses = witnesses
    }
    
    /// `delay` is needed to handle SwiftUI writing nil to navigation destination after new destination is already set.
    @available(*, deprecated, message: "Control delays in `getNavigation`.")
    public init(
        delay: Delay,
        getNavigation: @escaping GetNavigation,
        makeContent: @escaping MakeContent,
        schedulers: Schedulers = .init(),
        witnesses: Witnesses
    ) {
        self.delay = delay
        self.getNavigation = getNavigation
        self.makeContent = makeContent
        self.schedulers = schedulers
        self.witnesses = witnesses
    }
}

public extension BinderComposer {
    
    typealias Delay = DispatchQueue.SchedulerTimeType.Stride
    typealias GetNavigation = Domain.GetNavigation
    typealias MakeContent = () -> Content
    typealias Witnesses = Domain.Witnesses
    typealias Domain = BinderDomain<Content, Select, Navigation>
    
    func compose(
        initialState: Domain.FlowDomain.State = .init()
    ) -> Domain.Binder {
        
        let factory = ContentFlowBindingFactory()
        
        let flowComposer = Domain.FlowDomain.Composer(
            delay: delay,
            getNavigation: getNavigation,
            scheduler: schedulers.main,
            interactiveScheduler: schedulers.interactive
        )
        
        return .init(
            content: makeContent(),
            flow: flowComposer.compose(initialState: initialState),
            bind: factory.bind(with: .init(
                contentEmitting: witnesses.emitting,
                contentDismissing: witnesses.dismissing,
                flowEmitting: { $0.$state.map(\.navigation).eraseToAnyPublisher() },
                flowReceiving: { flow in { flow.event(.init($0)) }}
            ))
        )
    }
}

public extension FlowEvent {
    
    init(_ event: FlowEvent<Select, Never>) {
        
        switch event {
        case .dismiss:
            self = .dismiss
            
        case let .isLoading(isLoading):
            self = .isLoading(isLoading)
            
        case let .select(select):
            self = .select(select)
        }
    }
}
