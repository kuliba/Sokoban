//
//  RootViewDomain.swift
//  ForaBank
//
//  Created by Igor Malyarov on 07.11.2024.
//

import Combine
import PayHub
import PayHubUI

enum RootViewDomain<RootViewModel> {
    
    // MARK: - Binder
    
    typealias Binder = PayHub.Binder<Content, Flow>
    typealias BinderComposer = RootViewBinderComposer<Content>
    typealias GetNavigation = (Select, @escaping Notify, @escaping (Navigation) -> Void) -> Void
    
    struct Witnesses {
     
        let content: ContentWitnesses<Content, Select, Navigation>
        let dismiss: DismissWitnesses<Content>
        
        struct DismissWitnesses<T> {
            
            let dismissAll: (T) -> AnyPublisher<RootViewModelAction.DismissAll, Never>
            let reset: (T) -> () -> Void
        }
    }
    
    // MARK: - Content
    
    typealias Content = RootViewModel
    
    // MARK: - Flow
    
    typealias FlowDomain = PayHubUI.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    
    typealias Notify = (FlowDomain.NotifyEvent) -> Void
    
    enum Select {
        
        case scanQR
    }
    
    enum Navigation {
        
        case scanQR
    }
}
