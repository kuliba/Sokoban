//
//  OperationPickerFlowComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.08.2024.
//

import Combine
import CombineSchedulers
import Foundation
import PayHub

final class OperationPickerFlowComposer {
    
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    init(scheduler: AnySchedulerOf<DispatchQueue>) {
     
        self.scheduler = scheduler
    }
}

extension OperationPickerFlowComposer {
    
    func compose() -> OperationPickerFlow {
        
        let reducer = OperationPickerFlowReducer<ExchangeStub, Latest, LatestFlowStub, OperationPickerFlowStatus, TemplatesStub>()
        let effectHandler = OperationPickerFlowEffectHandler<ExchangeStub, Latest, LatestFlowStub, TemplatesStub>(
            microServices: .init(
                makeExchange: { .init() },
                makeLatestFlow: { _ in .init() },
                makeTemplates: { .init() }
            )
        )
        
        return .init(
            initialState: .init(),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: scheduler
        )
    }
}

extension ExchangeStub: FlowEventEmitter {
    
    var eventPublisher: AnyPublisher<PayHub.FlowEvent<OperationPickerFlowStatus>, Never> {
    
        Empty().eraseToAnyPublisher()
    }
}

extension LatestFlowStub: FlowEventEmitter {
    
    var eventPublisher: AnyPublisher<PayHub.FlowEvent<OperationPickerFlowStatus>, Never> {
    
        Empty().eraseToAnyPublisher()
    }
}

extension TemplatesStub: FlowEventEmitter {
    
    var eventPublisher: AnyPublisher<PayHub.FlowEvent<OperationPickerFlowStatus>, Never> {
    
        Empty().eraseToAnyPublisher()
    }
}
