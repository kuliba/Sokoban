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
        
        let content = TemplatesListViewModel(
            model,
            dismissAction: dismiss,
            updateFastAll: { [weak model] in
                
                model?.action.send(ModelAction.Products.Update.Fast.All())
            }
        )
        
        let reducer = TemplatesListFlowReducer<TemplatesListViewModel>()
        let microServices = TemplatesListFlowEffectHandlerMicroServices(
            makePayment: { template, close in
                
                return .legacy(.init(
                    source: .template(template.id),
                    model: self.model,
                    closeAction: close
                ))
            }
        )
        let effectHandler = TemplatesListFlowEffectHandler(
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
