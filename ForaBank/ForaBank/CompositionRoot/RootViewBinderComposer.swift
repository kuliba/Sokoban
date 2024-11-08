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
    
    private let schedulers: Schedulers
    
    init(schedulers: Schedulers = .init()) {
        
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
            bind: bind(with: witnesses())
        )
    }
}

private extension RootViewBinderComposer {
    
    func getNavigation(
        select: RootViewDomain.Select,
        notify: @escaping RootViewDomain.Notify,
        completion: @escaping (RootViewDomain.Navigation) -> Void
    ) {
        switch select {
        case .scanQR:
            completion(.scanQR)
        }
    }
    
    func bind(
        with witnesses: RootViewDomain.Witnesses
    ) -> (RootViewDomain.Content, RootViewDomain.Flow) -> Set<AnyCancellable> {
        
        let factory = ContentFlowBindingFactory(scheduler: schedulers.main)
        
        return factory.bind(with: witnesses)
    }
    
    func witnesses() -> RootViewDomain.Witnesses {
        
        return .init(
            contentEmitting: { _ in Empty().eraseToAnyPublisher() },
            contentReceiving: { _ in {}},
            flowEmitting: { $0.$state.map(\.navigation).eraseToAnyPublisher() },
            flowReceiving: { flow in { flow.event(.select($0)) }}
        )
    }
}
