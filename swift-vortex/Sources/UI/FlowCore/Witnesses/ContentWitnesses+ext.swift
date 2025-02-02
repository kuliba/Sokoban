//
//  ContentWitnesses+ext.swift
//
//
//  Created by Igor Malyarov on 04.01.2025.
//

import Combine
import RxViewModel

public extension ContentWitnesses {
    
    /// Creates a `Binder` that connects the specified content with a flow configured for advanced scenarios.
    ///
    /// This overload supports advanced functionalities—such as handling loading states (`isLoading`) and dismiss actions—by using a flow whose event type is wrapped in `FlowEvent<S, Never>`.
    ///
    /// - Parameters:
    ///   - content: The content instance to be bound.
    ///   - flow: A flow from the flow domain of type `FlowDomain<S, Navigation>.Flow`, enabling advanced event handling.
    /// - Returns: A `Binder` that binds the content with the provided flow using the standard binding logic.
    @inlinable
    func composeBinder<S, Navigation>(
        content: Content,
        flow: FlowDomain<S, Navigation>.Flow
    ) -> Binder<Content, FlowDomain<S, Navigation>.Flow>
    where Select == FlowEvent<S, Never> {
        
        return .init(content: content, flow: flow, bind: bind(content:flow:))
    }
    
    /// Creates a `Binder` that connects the specified content with a flow using a more restricted event mapping.
    ///
    /// This overload expects the flow's event type to directly match `Select`, mapping `Select` events into `FlowEvent.select(...)` only. It does not support advanced scenarios like `isLoading` or explicit dismiss actions.
    ///
    /// - Parameters:
    ///   - content: The content instance to be bound.
    ///   - flow: A flow from the flow domain of type `FlowDomain<Select, Navigation>.Flow`.
    /// - Returns: A `Binder` that binds the content with the provided flow using the standard binding logic.
    @inlinable
    func composeBinder<Navigation>(
        content: Content,
        flow: FlowDomain<Select, Navigation>.Flow
    ) -> Binder<Content, FlowDomain<Select, Navigation>.Flow> {
        
        return .init(content: content, flow: flow, bind: bind(content:flow:))
    }
    
    /// A convenience typealias representing an `RxViewModel` flow.
    typealias Flow<S, N> = RxViewModel<FlowState<N>, FlowEvent<S, N>, FlowEffect<S>>
    
    /// Binds `Content` and a flow using `FlowEvent<S, Never>` directly, allowing
    /// for advanced scenarios (e.g., `isLoading`, `dismiss`).
    ///
    /// This wraps everything into `ContentFlowWitnesses` so the parent flow can
    /// observe or react to these events appropriately.
    @inlinable
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
    @inlinable
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
