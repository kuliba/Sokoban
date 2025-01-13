//
//  RootDomain.Binder+default.swift
//  BinderComposerPreview
//
//  Created by Igor Malyarov on 14.12.2024.
//

import Combine
import CombineSchedulers
import FlowCore
import Foundation
import PayHub
import PayHubUI

extension RootDomain.Binder {
    
    /// - Note: - Change `delay`to see correct and incorrect navigation behavior: if delay is small, SwiftUI writes `nil` destination when switching from sheet after destination is already set. Looks like 500 ms is ok.
    static func `default`(
        delayPair: ContentView.DelayPair,
        schedulers: Schedulers = .init()
    ) -> RootDomain.Binder {
        
        let composer = RootDomain.BinderComposer(
            elements: RootDomain.Select.allCases,
            delay: .zero, // delay,
            getNavigation: { select, notify, completion in
                
                getNavigation(select: select, notify: notify) { navigation in
                    
                    switch navigation {
                    case let .destination(node):
                        schedulers.interactive.delay(for: delayPair.destination.value) {
                            
                            completion(.destination(node))
                        }
                        
                    case let .sheet(node):
                        schedulers.interactive.delay(for: delayPair.sheet.value) {
                            
                            completion(.sheet(node))
                        }
                    }
                }
            },
            schedulers: schedulers
        )
        
        return composer.compose()
        
        func getNavigation(
            select: RootDomain.Select,
            notify: @escaping RootDomain.Notify,
            completion: @escaping (RootDomain.Navigation) -> Void
        ) {
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
        }
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

extension AnySchedulerOf<DispatchQueue> {
    
    func delay(
        for timeout: Delay,
        _ action: @escaping () -> Void
    ) {
        schedule(after: now.advanced(by: timeout), action)
    }
    
    typealias Delay = DispatchQueue.SchedulerTimeType.Stride
}
