//
//  TemplatesListFlowModelComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.08.2024.
//

import Combine
import CombineSchedulers
import Foundation

final class TemplatesListFlowModelComposer {
    
    private let model: Model
    private let utilitiesPaymentsFlag: UtilitiesPaymentsFlag
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    init(
        model: Model,
        utilitiesPaymentsFlag: UtilitiesPaymentsFlag,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.model = model
        self.utilitiesPaymentsFlag = utilitiesPaymentsFlag
        self.scheduler = scheduler
    }
}

extension TemplatesListFlowModelComposer {
    
    func compose(
        dismiss: @escaping () -> Void
    ) -> TemplatesListFlowModel<TemplatesListViewModel> {
        
        let content = makeTemplates(dismiss: dismiss)
        let reducer = TemplatesListFlowReducer<TemplatesListViewModel>()
        let effectHandler = makeEffectHandler()
        
        return .init(
            initialState: .init(content: content),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: scheduler
        )
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
    
    func makeEffectHandler() -> TemplatesListFlowEffectHandler {
        
        let microServices = MicroServices(makePayment: makePayment)
        
        return .init(microServices: microServices)
    }
    
    typealias MicroServices = TemplatesListFlowEffectHandlerMicroServices
    
    private func makePayment(
        payload: MicroServices.MakePaymentPayload,
        completion: @escaping MicroServices.MakePaymentCompletion
    ) {
        let (template, close) = payload
        
        completion(.success(.legacy(.init(
            source: .template(template.id),
            model: .emptyMock,
            closeAction: close
        ))))
    }
}
