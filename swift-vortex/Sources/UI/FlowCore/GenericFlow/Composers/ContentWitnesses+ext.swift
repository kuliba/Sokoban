//
//  ContentWitnesses+ext.swift
//
//
//  Created by Igor Malyarov on 04.01.2025.
//

import Combine
import RxViewModel

public extension ContentWitnesses {
    
    /// A convenience typealias representing an `RxViewModel` flow.
    typealias Flow<S, N> = RxViewModel<FlowState<N>, FlowEvent<S, N>, FlowEffect<S>>
    
    /// Binds `Content` and a flow using `FlowEvent<S, Never>` directly, allowing
    /// for advanced scenarios (e.g., `isLoading`, `dismiss`).
    ///
    /// This wraps everything into `ContentFlowWitnesses` so the parent flow can
    /// observe or react to these events appropriately.
    func bind<S, N>(
        content: Content,
        flow: Flow<S, N>
    ) -> Set<AnyCancellable> where Select == FlowEvent<S, Never> {
        
        let witnesses = ContentFlowWitnesses<Content, Flow<S, N>, S, N>(
            contentEmitting: { emitting($0) },
            contentDismissing: { dismissing($0) },
            flowEmitting: { $0.$state.map(\.navigation).eraseToAnyPublisher() },
            flowReceiving: { flow in { flow.event(.init($0)) }}
        )
        
        return witnesses.bind(content: content, flow: flow)
    }
    
    /// Binds `Content` and a flow, transforming `Select` into `.select(...)` events.
    ///
    /// - Warning: This variant does not explicitly handle `isLoading` or `dismiss`. It relies on
    /// mapping `Select` into `FlowEvent.select(...)`.
    func bind<Navigation>(
        content: Content,
        flow: Flow<Select, Navigation>
    ) -> Set<AnyCancellable> {
        
        let witnesses = ContentWitnesses<Content, FlowEvent<Select, Never>>(
            emitting: { emitting($0).map(FlowEvent.select).eraseToAnyPublisher() },
            dismissing: { dismissing($0) }
        )
        
        return witnesses.bind(content: content, flow: flow)
    }
}
