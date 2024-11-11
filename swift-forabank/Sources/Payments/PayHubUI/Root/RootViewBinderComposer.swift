//
//  RootViewBinderComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 08.11.2024.
//

import Combine
import CombineSchedulers
import Foundation
import PayHub

public final class RootViewBinderComposer<RootViewModel, DismissAll> {
    
    private let bindings: Set<AnyCancellable>
    private let dismiss: () -> Void
    private let getNavigation: RootDomain.GetNavigation
    private let schedulers: Schedulers
    private let witnesses: RootDomain.Witnesses
    
    public init(
        bindings: Set<AnyCancellable>,
        dismiss: @escaping () -> Void,
        getNavigation: @escaping RootDomain.GetNavigation,
        schedulers: Schedulers = .init(),
        witnesses: RootDomain.Witnesses
    ) {
        self.bindings = bindings
        self.dismiss = dismiss
        self.getNavigation = getNavigation
        self.schedulers = schedulers
        self.witnesses = witnesses
    }
    
    public typealias RootDomain = RootViewDomain<RootViewModel, DismissAll>
}

public extension RootViewBinderComposer {
    
    func compose(
        with rootViewModel: RootViewModel
    ) -> RootDomain.Binder {
        
        let flowComposer = RootDomain.FlowDomain.Composer(
            getNavigation: getNavigation,
            scheduler: schedulers.main,
            interactiveScheduler: schedulers.interactive
        )
        
        return .init(
            content: rootViewModel,
            flow: flowComposer.compose(),
            bind: bind
        )
    }
}

private extension RootViewBinderComposer {
    
    func bind(
        content: RootDomain.Content,
        flow: RootDomain.Flow
    ) -> Set<AnyCancellable> {
        
        let factory = ContentFlowBindingFactory(scheduler: schedulers.main)
        let bind = factory.bind(with: .init(
            contentEmitting: witnesses.content.emitting,
            contentReceiving: witnesses.content.receiving,
            flowEmitting: { (flow: RootDomain.Flow) in
                
                flow.$state
                    .map(\RootDomain.FlowDomain.State.navigation).eraseToAnyPublisher()
            },
            flowReceiving: { flow in { flow.event(.select($0)) }}
        ))
        
        var bindings = bindings.union(bind(content, flow))
        bindings.insert(bindDismiss(content: content))
        
        return bindings
    }
    
    func bindDismiss(content: RootDomain.Content) -> AnyCancellable {
        
        let reset = witnesses.dismiss.reset(content)
        
        return witnesses.dismiss.dismissAll(content)
            .receive(on: schedulers.main)
            .sink { [unowned self] _ in
                
                self.dismiss()
                reset()
            }
    }
}
