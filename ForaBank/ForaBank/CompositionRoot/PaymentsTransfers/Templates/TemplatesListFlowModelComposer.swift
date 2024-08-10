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
    private let nanoServices: NanoServices
    private let utilitiesPaymentsFlag: UtilitiesPaymentsFlag
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    init(
        model: Model,
        nanoServices: NanoServices,
        utilitiesPaymentsFlag: UtilitiesPaymentsFlag,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.model = model
        self.nanoServices = nanoServices
        self.utilitiesPaymentsFlag = utilitiesPaymentsFlag
        self.scheduler = scheduler
    }
    
    typealias NanoServices = TemplatesListFlowEffectHandlerNanoServices
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
        
        switch utilitiesPaymentsFlag.rawValue {
        case .active(.live):
            makeV1Payment(template, completion)
            
        case .active(.stub):
            makeV1PaymentStub(template, completion)
            
        case .inactive:
            completion(.success(.legacy(
                makeLegacyPayment(template: template, close: close)
            )))
        }
    }
    
    private func makeV1Payment(
        _ template: PaymentTemplateData,
        _ completion: @escaping MicroServices.MakePaymentCompletion
    ) {
        nanoServices.initiatePayment(template) {
            
            switch $0 {
            case let .failure(serviceFailure):
                completion(.failure(serviceFailure))
                
            case let .success(node):
                completion(.success(.v1(node)))
            }
        }
    }
    
    private func makeV1PaymentStub(
        _ template: PaymentTemplateData,
        _ completion: @escaping MicroServices.MakePaymentCompletion
    ) {
        DispatchQueue.main.delay(for: .seconds(2)) {
            
            completion(.failure(.serverError("Cannot proceed with payment due to server error #65432")))
        }
    }
    
    private func makeLegacyPayment(
        template: PaymentTemplateData,
        close: @escaping () -> Void
    ) -> PaymentsViewModel {
        
        return .init(
            source: .template(template.id),
            model: .emptyMock,
            closeAction: close
        )
    }
}
