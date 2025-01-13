//
//  TemplatesListFlowModelComposer.swift
//  Vortex
//
//  Created by Igor Malyarov on 09.08.2024.
//

import Combine
import CombineSchedulers
import Foundation

final class TemplatesListFlowModelComposer {
    
    private let model: Model
    private let microServices: MicroServices
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    init(
        model: Model,
        microServices: MicroServices,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.model = model
        self.microServices = microServices
        self.scheduler = scheduler
    }
    
    typealias MicroServices = TemplatesListFlowEffectHandlerMicroServices<PaymentsViewModel, AnywayFlowModel>
}

extension TemplatesListFlowModelComposer {
    
    func compose(
        dismiss: @escaping () -> Void
    ) -> TemplatesListFlowModel<TemplatesListViewModel, AnywayFlowModel> {
        
        let content = makeTemplates(dismiss: dismiss)
        let reducer = TemplatesListFlowReducer<TemplatesListViewModel, AnywayFlowModel>()
        let effectHandler = TemplatesListFlowEffectHandler<AnywayFlowModel>(
            microServices: microServices
        )
        
        return .init(
            initialState: .init(content: content),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: scheduler
        )
    }
}

extension AnywayFlowModel: DismissAndTabFlowEventPublishing {
    
    var flowEventPublisher: AnyPublisher<DismissAndTabFlowEvent, Never> {
        
        $state
            .compactMap(\.flowEvent)
            .eraseToAnyPublisher()
    }
}

extension AnywayFlowState {
    
    var flowEvent: DismissAndTabFlowEvent? {
        
        return .init(isLoading: isLoading, status: flowEventStatus)
    }
    
    private var flowEventStatus: DismissAndTabFlowEvent.Status? {
        
        switch outside {
        case .none:     return .none
        case .main:     return .tab(.main)
        case .payments: return .tab(.payments)
        }
    }
}

private extension TemplatesListFlowModelComposer {
    
    func makeTemplates(
        dismiss: @escaping () -> Void
    ) -> TemplatesListViewModel {
        
        return .init(
            model,
            dismissAction: dismiss,
            updateFastAll: { [weak model] in
                
                model?.action.send(ModelAction.Products.Update.Fast.All())
            }
        )
    }
}
