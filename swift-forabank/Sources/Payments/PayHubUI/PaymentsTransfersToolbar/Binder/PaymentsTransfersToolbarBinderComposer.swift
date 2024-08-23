//
//  PaymentsTransfersToolbarBinderComposer.swift
//
//
//  Created by Igor Malyarov on 23.08.2024.
//

import Combine
import CombineSchedulers
import Foundation
import PayHub
import RxViewModel

public final class PaymentsTransfersToolbarBinderComposer<Profile, QR> {
    
    private let microServices: MicroServices
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    public init(
        microServices: MicroServices,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.microServices = microServices
        self.scheduler = scheduler
    }
    
    public typealias MicroServices = PaymentsTransfersToolbarFlowEffectHandlerMicroServices<Profile, QR>
}

public extension PaymentsTransfersToolbarBinderComposer {
    
    func compose(
        selection: PaymentsTransfersToolbarState.Selection? = nil
    ) -> Binder<Content, Flow> {
        
        let content = makeContent(selection: selection)
        let flow = makeFlow()
        
        return .init(content: content, flow: flow, bind: bind)
    }
    
    typealias Content = PaymentsTransfersToolbarContent
    typealias Flow = PaymentsTransfersToolbarFlow<Profile, QR>
}

// MARK: - Content

private extension PaymentsTransfersToolbarBinderComposer {
    
    func makeContent(
        selection: PaymentsTransfersToolbarState.Selection?
    ) -> Content {
        
        let reducer = PaymentsTransfersToolbarReducer()
        let effectHandler = PaymentsTransfersToolbarEffectHandler(
            microServices: .init()
        )
        
        return .init(
            initialState: .init(selection: selection),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: scheduler
        )
    }
}

// MARK: - Flow

private extension PaymentsTransfersToolbarBinderComposer {
    
    func makeFlow() -> Flow {
        
        let reducer = PaymentsTransfersToolbarFlowReducer<Profile, QR>()
        let effectHandler = PaymentsTransfersToolbarFlowEffectHandler(
            microServices: microServices
        )
        
        return .init(
            initialState: .init(),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: scheduler
        )
    }
}

// MARK: - bind

private extension PaymentsTransfersToolbarBinderComposer {
    
    func bind(
        _ content: Content,
        _ flow: Flow
    ) -> Set<AnyCancellable> {
        
        let flowNavigation = flow.$state.map(\.navigation)
        let dismiss = flowNavigation
            .combineLatest(flowNavigation.dropFirst())
            .filter { $0.0 != nil && $0.1 == nil }
            .debounce(for: .milliseconds(100), scheduler: scheduler)
            .sink { _ in content.event(.select(nil)) }
        
        let select = content.$state
            .compactMap(\.selection)
            .sink {
                
                switch $0 {
                case .profile:
                    flow.event(.select(.profile))
                case .qr:
                    flow.event(.select(.qr))
                }
            }
        
        return [dismiss, select]
    }
}
