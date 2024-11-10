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
import PayHubUI

final class RootViewBinderComposer<RootViewModel> {
    
    private let bindings: Set<AnyCancellable>
    private let dismiss: () -> Void
    private let getNavigation: RootDomain.GetNavigation
    private let schedulers: Schedulers
    private let witnesses: RootDomain.Witnesses
    
    init(
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
    
    typealias RootDomain = RootViewDomain<RootViewModel>
}

extension RootViewBinderComposer {
    
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
        let bind = factory.bind(with: witnesses.contentFlow)
        
        var bindings = bindings.union(bind(content, flow))
        bindings.insert(bindDismiss(content: content))
        
        return bindings
    }
    
    func bindDismiss(content: RootDomain.Content) -> AnyCancellable {
        
        let dismiss = witnesses.dismiss.reset(content)
        
        return witnesses.dismiss.dismissAll(content)
            .receive(on: schedulers.main)
            .sink { [unowned self] _ in
                
                self.dismiss()
                dismiss()
            }
    }
}
