//
//  PaymentProviderServicePickerFlowModelComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 24.07.2024.
//

import CombineSchedulers
import ForaTools
import Foundation

final class PaymentProviderServicePickerFlowModelComposer {
    
    // TODO: suboptimal, need to rethink how to inject what needed
    // (and that is `AsyncPickerEffectHandlerMicroServices`)
    private let composer: Composer
    private let factory: Factory
    private let model: Model
    private let nanoServices: NanoServices
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    init(
        composer: Composer,
        factory: Factory,
        model: Model,
        nanoServices: NanoServices,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.composer = composer
        self.factory = factory
        self.model = model
        self.nanoServices = nanoServices
        self.scheduler = scheduler
    }
    
    typealias Composer = UtilityPrepaymentFlowMicroServicesComposer
    typealias Factory = PaymentProviderServicePickerFlowModelFactory
    typealias NanoServices = UtilityPaymentNanoServices
}

extension PaymentProviderServicePickerFlowModelComposer {
    
    func makeFlowModel(
        payload: PaymentProviderServicePickerPayload
    ) -> PaymentProviderServicePickerFlowModel {
        
        let content = makePaymentProviderServicePickerModel(payload: payload)
        let flowReducer = PaymentProviderServicePickerFlowReducer()
        let flowEffectHandler = PaymentProviderServicePickerFlowEffectHandler(
            makePayByInstructionModel: { completion in
                
                let viewModel = PaymentsViewModel(
                    self.model,
                    service: .requisites,
                    closeAction: {}
                )
                completion(viewModel)
            }
        )
        
        return .init(
            initialState: .init(content: content),
            factory: factory,
            reduce: flowReducer.reduce(_:_:),
            handleEffect: flowEffectHandler.handleEffect(_:_:),
            scheduler: scheduler
        )
    }
}

extension PaymentProviderServicePickerFlowModelComposer {
    
    func makePaymentProviderServicePickerModel(
        payload: PaymentProviderServicePickerPayload
    ) -> PaymentProviderServicePickerModel {
        
        let reducer = PickerReducer()
        let effectHandler = PickerEffectHandler(
            microServices: .init(
                load: load,
                select: { service, completion in
                    
                    // TODO: needs simplification and decoupling from `nanoServices.startAnywayPayment` which much more complex than is needed in this case
                    self.nanoServices.startAnywayPayment(
                        .service(service, for: payload.provider.operator)
                    ) {
                        // TODO: get rid of this dependency
                        let result = self.composer.makeStartPaymentResult(from: $0, service, payload.provider.operator)
                        
                        switch result {
                        case let .failure(.serviceFailure(.serverError(errorMessage))):
                            completion(.failure(.serverError(errorMessage)))
                            
                        case let .success(.startPayment(transaction)):
                            completion(.success(transaction))
                            
                        default:
                            completion(.failure(.connectivityError))
                        }
                    }
                }
            )
        )
        
        return .init(
            initialState: .init(payload: payload),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: scheduler
        )
    }
    
    typealias PickerReducer = AsyncPickerReducer<PaymentProviderServicePickerPayload, UtilityService, Result>
    typealias PickerEffectHandler = AsyncPickerEffectHandler<PaymentProviderServicePickerPayload, UtilityService, Result>
    
    typealias MicroServices = AsyncPickerEffectHandlerMicroServices<PaymentProviderServicePickerPayload, UtilityService, Result>
    
    typealias Provider = SegmentedPaymentProvider
    typealias Result = PaymentProviderServicePickerResult
}

private extension PaymentProviderServicePickerFlowModelComposer {
    
    func load(
        payload: PaymentProviderServicePickerPayload,
        completion: @escaping ([UtilityService]) -> Void
    ) {
        nanoServices.getServicesFor(payload.provider.operator) {
            
            completion((try? $0.get()) ?? [])
            _ = self.nanoServices
        }
    }
}

private extension SegmentedPaymentProvider {
    
    var `operator`: UtilityPaymentOperator {
        
        return .init(id: id, title: title, subtitle: inn, icon: icon)
    }
}
