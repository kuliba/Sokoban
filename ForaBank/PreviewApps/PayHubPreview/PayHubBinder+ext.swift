//
//  PayHubBinder+ext.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

import Combine
import CombineSchedulers
import Foundation
import PayHub
import RxViewModel

#warning("extract to files")
#warning("remove public")

public struct Latest: Equatable {
    
    let id: String
}

public final class Exchange: FlowEventEmitter {
    
    private let subject = PassthroughSubject<FlowEvent<Status>, Never>()
    
    public var eventPublisher: AnyPublisher<FlowEvent<Status>, Never> {
        
        subject.eraseToAnyPublisher()
    }
}

public final class LatestFlow: FlowEventEmitter {
    
    let latest: Latest
    
    private let subject = PassthroughSubject<FlowEvent<Status>, Never>()
    
    init(
        latest: Latest
    ) {
        self.latest = latest
    }
    
    public var eventPublisher: AnyPublisher<FlowEvent<Status>, Never> {
        
        subject.eraseToAnyPublisher()
    }
}

public final class Templates: FlowEventEmitter {
    
    private let subject = PassthroughSubject<FlowEvent<Status>, Never>()
    
    public var eventPublisher: AnyPublisher<FlowEvent<Status>, Never> {
        
        subject.eraseToAnyPublisher()
    }
}

public enum Status: Equatable {
    
    case main
}

public typealias PayHubState = PayHub.PayHubState<Latest>
typealias PayHubEvent = PayHub.PayHubEvent<Latest>
typealias PayHubEffect = PayHub.PayHubEffect

typealias PayHubReducer = PayHub.PayHubReducer<Latest>
typealias PayHubEffectHandler = PayHub.PayHubEffectHandler<Latest>

typealias PayHubContent = RxViewModel<PayHubState, PayHubEvent, PayHubEffect>

public typealias PayHubFlowState = PayHub.PayHubFlowState<Exchange, LatestFlow, Status, Templates>
public typealias PayHubFlowEvent = PayHub.PayHubFlowEvent<Exchange, Latest, LatestFlow, Status, Templates>
typealias PayHubFlowEffect = PayHub.PayHubFlowEffect<Latest>

typealias PayHubFlowReducer = PayHub.PayHubFlowReducer<Exchange, Latest, LatestFlow, Status, Templates>
typealias PayHubFlowEffectHandler = PayHub.PayHubFlowEffectHandler<Exchange, Latest, LatestFlow, Templates>

typealias PayHubFlow = RxViewModel<PayHubFlowState, PayHubFlowEvent, PayHubFlowEffect>

extension PayHubContent {
    
    static func stub(
        initialState: PayHubState = .none,
        loadResult: PayHubEffectHandler.MicroServices.LoadResult,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) -> PayHubContent {
        
        let reducer = PayHubReducer()
        let effectHandler = PayHubEffectHandler(
            microServices: .init(
                load: { completion in
                
                    scheduler.schedule(
                        after: .init(.now().advanced(by: .seconds(2)))
                    ) {
                        completion(loadResult)
                    }
                }
            )
        )
        
        return .init(
            initialState: initialState,
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: scheduler
        )
    }
}

extension PayHubFlow {
    
    static func make(
        initialState: PayHubFlowState = .init(),
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) -> PayHubFlow {
        
        let reducer = PayHubFlowReducer()
        let effectHandler = PayHubFlowEffectHandler(
            microServices: .init(
                makeExchange: Exchange.init,
                makeLatestFlow: LatestFlow.init,
                makeTemplates: Templates.init
            )
        )
        
        return .init(
            initialState: initialState, 
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: scheduler
        )
    }
}
