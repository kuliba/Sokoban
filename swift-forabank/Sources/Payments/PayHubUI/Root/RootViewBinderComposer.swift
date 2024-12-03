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

public final class RootViewBinderComposer<RootViewModel, DismissAll, Select, Navigation> {
    
    private let bindings: Set<AnyCancellable>
    private let dismiss: () -> Void
    private let getNavigation: RootDomain.GetNavigation
    // TODO: - move to witness
    private let bindOutside: BindOutside
    private let schedulers: Schedulers
    private let witnesses: RootDomain.Witnesses
    
    public init(
        bindings: Set<AnyCancellable>,
        dismiss: @escaping () -> Void,
        getNavigation: @escaping RootDomain.GetNavigation,
        bindOutside: @escaping BindOutside,
        schedulers: Schedulers = .init(),
        witnesses: RootDomain.Witnesses
    ) {
        self.bindings = bindings
        self.dismiss = dismiss
        self.getNavigation = getNavigation
        self.bindOutside = bindOutside
        self.schedulers = schedulers
        self.witnesses = witnesses
    }
    
    public typealias RootDomain = RootViewDomain<RootViewModel, DismissAll, Select, Navigation>
    public typealias BindOutside = (RootDomain.Content, RootDomain.Flow) -> Set<AnyCancellable>
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
            contentDismissing: witnesses.content.dismissing,
            flowEmitting: { (flow: RootDomain.Flow) in
                
                flow.$state
                    .map(\RootDomain.FlowDomain.State.navigation)
                    .eraseToAnyPublisher()
            },
            flowReceiving: { flow in { flow.event(.select($0)) }}
        ))
        
        var bindings = bindings.union(bind(content, flow))
        bindings.formUnion(bindOutside(content, flow))
        bindings.insert(bindDismiss(content: content))
        
        return bindings
    }
    
    func bindDismiss(content: RootDomain.Content) -> AnyCancellable {
        
        let reset = witnesses.dismiss.reset(content)
        
        return witnesses.dismiss.dismissAll(content)
            .receive(on: schedulers.main)
            .sink { [dismiss] _ in
                
                dismiss()
                reset()
            }
    }
}
