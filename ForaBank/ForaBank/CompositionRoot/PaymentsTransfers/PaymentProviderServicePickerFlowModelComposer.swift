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
    private let nanoServices: NanoServices
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    init(
        composer: Composer,
        factory: Factory,
        nanoServices: NanoServices,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.composer = composer
        self.factory = factory
        self.nanoServices = nanoServices
        self.scheduler = scheduler
    }
    
    typealias Composer = UtilityPrepaymentFlowMicroServicesComposer
    typealias Factory = PaymentProviderServicePickerFlowModelFactory
    typealias NanoServices = UtilityPaymentNanoServices
}

extension PaymentProviderServicePickerFlowModelComposer {
    
    func makeFlowModel(
        provider: PaymentProviderSegment.Provider
    ) -> PaymentProviderServicePickerFlowModel {
        
        #warning("implement instead of fatalError()")
        let content = makePaymentProviderServicePickerModel(provider: provider)
        let flowReducer = PaymentProviderServicePickerFlowReducer()
        let flowEffectHandler = PaymentProviderServicePickerFlowEffectHandler(
            makePayByInstructionModel: { _ in fatalError() }
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
        provider: PaymentProviderSegment.Provider
    ) -> PaymentProviderServicePickerModel {
        
        let reducer = PickerReducer()
        let effectHandler = PickerEffectHandler(
            microServices: .init(
                load: load,
                select: { service, completion in
                    
                    // TODO: needs simplification and decoupling from `nanoServices.startAnywayPayment` which much more complex than is needed in this case
                    self.nanoServices.startAnywayPayment(
                        .service(service, for: provider.operator)
                    ) {
                        // TODO: get rid of this dependency
                        let result = self.composer.makeStartPaymentResult(from: $0, service, provider.operator)
                        
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
            initialState: .init(payload: provider),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: scheduler
        )
    }
    
    typealias PickerReducer = AsyncPickerReducer<Provider, UtilityService, Result>
    typealias PickerEffectHandler = AsyncPickerEffectHandler<Provider, UtilityService, Result>
    
    typealias MicroServices = AsyncPickerEffectHandlerMicroServices<Provider, UtilityService, Result>
    
    typealias Provider = PaymentProviderSegment.Provider
    typealias Result = PaymentProviderServicePickerResult
}

private extension PaymentProviderServicePickerFlowModelComposer {
    
    func load(
        provider: PaymentProviderSegment.Provider,
        completion: @escaping ([UtilityService]) -> Void
    ) {
        nanoServices.getServicesFor(provider.operator) {
            
            completion((try? $0.get()) ?? [])
            _ = self.nanoServices
        }
    }
}

private extension PaymentProviderSegment.Provider {
    
    var `operator`: UtilityPaymentOperator {
        
        return .init(id: id, title: title, subtitle: inn, icon: icon)
    }
}
