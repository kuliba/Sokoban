//
//  PaymentProviderServicePickerFlowModelComposer.swift
//  Vortex
//
//  Created by Igor Malyarov on 24.07.2024.
//

import CombineSchedulers
import VortexTools
import Foundation

@available(*, deprecated, message: "use AnywayServicePickerFlowModelComposer instead")
final class PaymentProviderServicePickerFlowModelComposer {
    
    private let factory: Factory
    private let makeMicroServices: MakeMicroServices
    private let model: Model
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    init(
        factory: Factory,
        makeMicroServices: @escaping MakeMicroServices,
        model: Model,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.factory = factory
        self.makeMicroServices = makeMicroServices
        self.model = model
        self.scheduler = scheduler
    }
    
    typealias Factory = PaymentProviderServicePickerFlowModelFactory
    typealias MakeMicroServices = () -> MicroServices
    typealias MicroServices = AsyncPickerEffectHandlerMicroServices<PaymentProviderServicePickerPayload, ServicePickerItem, PaymentProviderServicePickerResult>
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
        
        let microServices = makeMicroServices()
        let effectHandler = PickerEffectHandler(microServices: microServices)
        
        return .init(
            initialState: .init(payload: payload),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: scheduler
        )
    }
    
    typealias PickerReducer = AsyncPickerReducer<PaymentProviderServicePickerPayload, ServicePickerItem, Result>
    typealias PickerEffectHandler = AsyncPickerEffectHandler<PaymentProviderServicePickerPayload, ServicePickerItem, Result>
    
    typealias Provider = SegmentedPaymentProvider
    typealias Result = PaymentProviderServicePickerResult
}
