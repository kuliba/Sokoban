//
//  RootViewDomain.swift
//  ForaBank
//
//  Created by Igor Malyarov on 07.11.2024.
//

import Combine
import PayHub

/// A namespace.
public enum RootViewDomain<RootViewModel, DismissAll> {}

public extension RootViewDomain {
    
    // MARK: - Binder
    
    typealias Binder = PayHub.Binder<Content, Flow>
    typealias BinderComposer = RootViewBinderComposer<Content, DismissAll>
    typealias GetNavigation = (Select, @escaping Notify, @escaping (Navigation) -> Void) -> Void
    
    struct Witnesses {
        
        public let content: ContentWitnesses<Content, Select, Navigation>
        public let dismiss: DismissWitnesses<Content>
        
        public init(
            content: ContentWitnesses<Content, Select, Navigation>, 
            dismiss: DismissWitnesses<Content>
        ) {
            self.content = content
            self.dismiss = dismiss
        }
        
        public struct DismissWitnesses<T> {
            
            public let dismissAll: (T) -> AnyPublisher<DismissAll, Never>
            public let reset: (T) -> () -> Void
            
            public init(
                dismissAll: @escaping (T) -> AnyPublisher<DismissAll, Never>,
                reset: @escaping (T) -> () -> Void
            ) {
                self.dismissAll = dismissAll
                self.reset = reset
            }
        }
    }
    
    // MARK: - Content
    
    typealias Content = RootViewModel
    
    // MARK: - Flow
    
    typealias FlowDomain = PayHubUI.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    
    typealias Notify = (FlowDomain.NotifyEvent) -> Void
    
    enum Select: Equatable {
        
        case scanQR
    }
    
    enum Navigation {
        
        case scanQR
    }
}
