//
//  RootDomain.Binder+default.swift
//  BinderComposerPreview
//
//  Created by Igor Malyarov on 14.12.2024.
//

import Combine
import PayHub
import PayHubUI

extension RootDomain.Binder {
    
    static func `default`(
        schedulers: Schedulers = .init()
    ) -> RootDomain.Binder {
        
        let composer = RootDomain.BinderComposer(
            elements: RootDomain.Select.allCases,
            getNavigation: { select, notify, completion in
                
                
                switch select {
                case .destination:
                    completion(.destination(makeDestinationNode(next: .sheet)))
                    
                case .sheet:
                    completion(.sheet(makeDestinationNode(next: .destination)))
                }
                
                func makeDestinationNode(
                    next: RootDomain.Select
                ) -> Node<DestinationDomain.Content> {
                    
                    let composer = DestinationDomain.Composer(scheduler: .main)
                    let destination = composer.compose(
                        elements: DestinationDomain.Element.allCases
                    )
                    
                    return .init(
                        model: destination,
                        cancellables: bind(destination, to: notify, next: next)
                    )
                }
                
                func bind(
                    _ content: DestinationDomain.Content,
                    to notify: @escaping RootDomain.Notify,
                    next: RootDomain.Select
                ) -> Set<AnyCancellable> {
                    
                    let share = content.$state.share()
                    
                    let close = share.compactMap(\.selection?.close)
                        .sink { notify(.dismiss) }
                    
                    let next = share.compactMap(\.selection?.next)
                        .sink { notify(.select(next)) }
                    
                    return [close, next]
                }
            },
            schedulers: schedulers
        )
        
        return composer.compose()
    }
}

private extension DestinationDomain.Element {
    
    var close: Void? {
        
        guard case .close = self else { return nil }
        return ()
    }
    
    var next: Void? {
        
        guard case .next = self else { return nil }
        return ()
    }
}

