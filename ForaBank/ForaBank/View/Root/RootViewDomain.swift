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
    typealias BinderComposer = RootViewBinderComposer<RootViewModel>
    typealias GetNavigation = (RootViewDomain.Select, @escaping RootViewDomain.Notify, @escaping (RootViewDomain.Navigation) -> Void) -> Void
    
    struct Witnesses {
     
        let contentFlow: ContentFlowWitnesses<Content, Flow, Select, Navigation>
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

extension RootViewDomain<RootViewModel>.Witnesses {
    
    static let `default`: Self = .init(
        contentFlow: .init(
            contentEmitting: { _ in Empty().eraseToAnyPublisher() },
            contentReceiving: { _ in {}},
            flowEmitting: { $0.$state.map(\.navigation).eraseToAnyPublisher() },
            flowReceiving: { flow in { flow.event(.select($0)) }}
        ),
        dismiss: .init(
            dismissAll: {
                
                $0.action
                    .compactMap { $0 as? RootViewModelAction.DismissAll }
                    .eraseToAnyPublisher()
            },
            reset: { content in
                
                return {
                    
                    content.resetLink()
                    content.reset()
                }
            }
        )
    )
}
