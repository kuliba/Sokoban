//
//  BinderComposer.swift
//
//
//  Created by Igor Malyarov on 10.11.2024.
//

import Foundation

public final class BinderComposer<Content, Select, Navigation> {
    
    private let delay: Delay
    private let getNavigation: GetNavigation
    private let makeContent: MakeContent
    private let schedulers: Schedulers
    private let witnesses: Witnesses
    
    public init(
        delay: Delay = .milliseconds(100),
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
        
        let factory = ContentFlowBindingFactory(
            delay: delay,
            scheduler: schedulers.interactive
        )
        
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
                flowReceiving: { flow in { flow.event(.select($0)) }}
            ))
        )
    }
}
