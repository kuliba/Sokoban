//
//  RootViewDomain.swift
//  Vortex
//
//  Created by Igor Malyarov on 07.11.2024.
//

import Combine
import FlowCore

/// A namespace.
public enum RootViewDomain<RootViewModel, DismissAll, Select, Navigation> {}

public extension RootViewDomain {
    
    // MARK: - Binder
    
    typealias Binder = FlowCore.Binder<Content, Flow>
    typealias BinderComposer = RootViewBinderComposer<Content, DismissAll, Select, Navigation>
    
    // MARK: - Content
    
    typealias Content = RootViewModel
    
    // MARK: - Flow
    
    typealias FlowDomain = FlowCore.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    
    typealias Notify = (FlowDomain.NotifyEvent) -> Void
    
    // MARK: -  other
    
    typealias GetNavigation = (Select, @escaping Notify, @escaping (Navigation) -> Void) -> Void
    
    struct Witnesses {
        
        public let content: ContentWitnesses
        public let dismiss: DismissWitnesses<Content>
        
        public init(
            content: ContentWitnesses,
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
    
    typealias ContentWitnesses = FlowCore.ContentWitnesses<Content, FlowDomain.NotifyEvent>
}
