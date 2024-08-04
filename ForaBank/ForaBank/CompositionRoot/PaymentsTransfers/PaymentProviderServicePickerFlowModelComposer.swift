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
    
    private let makeMicroServices: MakeMicroServices
    private let factory: Factory
    private let model: Model
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    init(
        makeMicroServices: @escaping MakeMicroServices,
        factory: Factory,
        model: Model,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.makeMicroServices = makeMicroServices
        self.factory = factory
        self.model = model
        self.scheduler = scheduler
    }
    
    typealias Factory = PaymentProviderServicePickerFlowModelFactory
    typealias MakeMicroServices = (PaymentProviderServicePickerPayload) -> MicroServices
    typealias MicroServices = AsyncPickerEffectHandlerMicroServices<PaymentProviderServicePickerPayload, UtilityService, PaymentProviderServicePickerResult>
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
            microServices: makeMicroServices(payload)
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
    
    typealias Provider = SegmentedPaymentProvider
    typealias Result = PaymentProviderServicePickerResult
}
