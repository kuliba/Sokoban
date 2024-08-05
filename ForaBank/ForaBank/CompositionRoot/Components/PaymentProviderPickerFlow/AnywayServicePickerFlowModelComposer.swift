//
//  AnywayServicePickerFlowModelComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 04.08.2024.
//

import CombineSchedulers
import ForaTools
import Foundation

final class AnywayServicePickerFlowModelComposer {
    
    private let makeAnywayFlowModel: MakeAnywayFlowModel
    private let microServices: MicroServices
    private let model: Model
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    init(
        makeAnywayFlowModel: @escaping MakeAnywayFlowModel,
        microServices: MicroServices,
        model: Model,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.makeAnywayFlowModel = makeAnywayFlowModel
        self.microServices = microServices
        self.model = model
        self.scheduler = scheduler
    }

    typealias MakeAnywayFlowModel = (AnywayTransactionState.Transaction) -> AnywayFlowModel
    typealias MicroServices = AsyncPickerEffectHandlerMicroServices<PaymentProviderServicePickerPayload, UtilityService, PaymentProviderServicePickerResult>
}

extension AnywayServicePickerFlowModelComposer {
    
    func compose(
        provider: SegmentedProvider,
        qrCode: QRCode
    ) -> AnywayServicePickerFlowModel {
        
        return .init(
            initialState: .init(
                content: makeContent(provider, qrCode)
            ),
            factory: makeFactory(),
            scheduler: scheduler
        )
    }
}

private extension AnywayServicePickerFlowModelComposer {
    
    func makeContent(
        _ provider: SegmentedProvider,
        _ qrCode: QRCode
    ) -> PaymentProviderServicePickerModel {
        
        let reducer = AsyncPickerReducer<PaymentProviderServicePickerPayload, UtilityService, PaymentProviderServicePickerResult>()
        let effectHandler = AsyncPickerEffectHandler(
            microServices: microServices
        )
        
        return .init(
            initialState: .init(
                payload: .init(
                    provider: .init(provider),
                    qrCode: qrCode
                )
            ),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: scheduler
        )
    }
    
    func makeFactory() -> AnywayServicePickerFlowModelFactory {
        
        return .init(
            makeAnywayFlowModel: makeAnywayFlowModel,
            makePayByInstructionsViewModel: {
                
                return .init(self.model, service: .requisites, closeAction: $0)
            }
        )
    }
}

// MARK: - Adapters

private extension SegmentedPaymentProvider {
    
    init(_ provider: SegmentedProvider) {
        
        self.init(
            id: provider.origin.id,
            icon: provider.origin.icon,
            inn: provider.origin.inn,
            title: provider.origin.title,
            segment: provider.segment
        )
    }
}
