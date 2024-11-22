//
//  RootViewModelFactory+compose.swift
//  ForaBank
//
//  Created by Igor Malyarov on 21.11.2024.
//

import PayHub
import PayHubUI
import RxViewModel

extension RootViewModelFactory {
    
    func compose<Content, Select, Navigation>(
        initialState: BinderComposer<Content, Select, Navigation>.Domain.FlowDomain.State = .init(),
        getNavigation: @escaping BinderComposer<Content, Select, Navigation>.GetNavigation,
        content: Content,
        witnesses: BinderComposer<Content, Select, Navigation>.Witnesses
    ) -> Binder<Content, RxViewModel<PayHub.FlowState<Navigation>, PayHub.FlowEvent<Select, Navigation>, PayHub.FlowEffect<Select>>> {
        
        let composer = BinderComposer(
            delay: settings.delay,
            getNavigation: getNavigation,
            makeContent: { content },
            schedulers: schedulers,
            witnesses: witnesses
        )
        
        return composer.compose(initialState: initialState)
    }
}
