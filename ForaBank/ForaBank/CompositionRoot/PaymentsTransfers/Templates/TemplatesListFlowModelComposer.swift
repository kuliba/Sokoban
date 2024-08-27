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
    
    private let makeAnywayFlowModel: MakeAnywayFlowModel
    private let model: Model
    private let nanoServices: NanoServices
    private let utilitiesPaymentsFlag: UtilitiesPaymentsFlag
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    init(
        makeAnywayFlowModel: @escaping MakeAnywayFlowModel,
        model: Model,
        nanoServices: NanoServices,
        utilitiesPaymentsFlag: UtilitiesPaymentsFlag,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.makeAnywayFlowModel = makeAnywayFlowModel
        self.model = model
        self.nanoServices = nanoServices
        self.utilitiesPaymentsFlag = utilitiesPaymentsFlag
        self.scheduler = scheduler
    }
    
    typealias MakeAnywayFlowModel = (AnywayTransactionState.Transaction) -> AnywayFlowModel
    typealias NanoServices = TemplatesListFlowEffectHandlerNanoServices
}

extension TemplatesListFlowModelComposer {
    
    func compose(
        dismiss: @escaping () -> Void
    ) -> TemplatesListFlowModel<TemplatesListViewModel, AnywayFlowModel> {
        
        let content = makeTemplates(dismiss: dismiss)
        let reducer = TemplatesListFlowReducer<TemplatesListViewModel, AnywayFlowModel>()
        let effectHandler = makeEffectHandler()
        
        return .init(
            initialState: .init(content: content),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: scheduler
        )
    }
}

extension AnywayFlowModel: FlowEventPublishing {
    
    var flowEventPublisher: AnyPublisher<FlowEvent, Never> {
        
        $state
            .compactMap(\.flowEvent)
            .eraseToAnyPublisher()
    }
}

extension AnywayFlowState {
    
    var flowEvent: FlowEvent? {
        
        return .init(isLoading: isLoading, status: flowEventStatus)
    }
    
    private var flowEventStatus: FlowEvent.Status? {
        
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
    
    func makeEffectHandler() -> TemplatesListFlowEffectHandler<AnywayFlowModel> {
        
        let microServices = MicroServices(makePayment: makePayment)
        
        return .init(microServices: microServices)
    }
    
    typealias MicroServices = TemplatesListFlowEffectHandlerMicroServices<PaymentsViewModel, AnywayFlowModel>
    
    private func makePayment(
        payload: MicroServices.MakePaymentPayload,
        completion: @escaping MicroServices.MakePaymentCompletion
    ) {
        let (template, close) = payload
        
        switch template.type {
        case .housingAndCommunalService:
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
            
        default:
            completion(.success(.legacy(
                makeLegacyPayment(template: template, close: close)
            )))
        }
    }
    
    private func makeV1Payment(
        _ template: PaymentTemplateData,
        _ completion: @escaping MicroServices.MakePaymentCompletion
    ) {
        nanoServices.initiatePayment(template) { [weak self] in
            
            guard let self else { return }
            
            switch $0 {
            case let .failure(serviceFailure):
                completion(.failure(serviceFailure))
                
            case let .success(transaction):
                completion(.success(.v1(makeAnywayFlowModel(transaction))))
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
            model: model,
            closeAction: close
        )
    }
}
