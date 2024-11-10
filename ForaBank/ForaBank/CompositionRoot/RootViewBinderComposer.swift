//
//  RootViewBinderComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 08.11.2024.
//

import Combine
import CombineSchedulers
import Foundation
import PayHubUI

final class RootViewBinderComposer {
    
    private let bindings: Set<AnyCancellable>
    private let dismiss: () -> Void
    private let getNavigation: RootViewDomain.GetNavigation
    private let schedulers: Schedulers
    
    init(
        bindings: Set<AnyCancellable>,
        dismiss: @escaping () -> Void,
        getNavigation: @escaping RootViewDomain.GetNavigation,
        schedulers: Schedulers = .init()
    ) {
        self.bindings = bindings
        self.dismiss = dismiss
        self.getNavigation = getNavigation
        self.schedulers = schedulers
    }
}

extension RootViewBinderComposer {
    
    func compose(
        with rootViewModel: RootViewModel
    ) -> RootViewDomain.Binder {
        
        let flowComposer = RootViewDomain.FlowDomain.Composer(
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
        content: RootViewDomain.Content,
        flow: RootViewDomain.Flow
    ) -> Set<AnyCancellable> {
        
        let factory = ContentFlowBindingFactory(scheduler: schedulers.main)
        let bind = factory.bind(with: witnesses())
        
        var bindings = bindings.union(bind(content, flow))
        bindings.insert(bindDismiss(content: content))
        
        return bindings
    }
    
    func witnesses() -> RootViewDomain.Witnesses {
        
        return .init(
            contentEmitting: { _ in Empty().eraseToAnyPublisher() },
            contentReceiving: { _ in {}},
            flowEmitting: { $0.$state.map(\.navigation).eraseToAnyPublisher() },
            flowReceiving: { flow in { flow.event(.select($0)) }}
        )
    }
    
    func bindDismiss(content: RootViewDomain.Content) -> AnyCancellable {
        
        content.action
            .compactMap { $0 as? RootViewModelAction.DismissAll }
            .receive(on: schedulers.main)
            .sink { [unowned self] _ in
                
                self.dismiss()
                content.resetLink()
                content.reset()
            }
    }
}
