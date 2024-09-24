//
//  PaymentProviderPickerFlowModelComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 04.08.2024.
//

import CombineSchedulers
import ForaTools
import Foundation

final class PaymentProviderPickerFlowModelComposer {

    private let makeServicePickerFlowModel: MakeServicePickerFlowModel
    private let model: Model
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    init(
        makeServicePickerFlowModel: @escaping MakeServicePickerFlowModel,
        model: Model,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.makeServicePickerFlowModel = makeServicePickerFlowModel
        self.model = model
        self.scheduler = scheduler
    }
    
    typealias MakeServicePickerFlowModel = SegmentedPaymentProviderPickerFlowFactory.MakeServicePickerFlowModel
}

extension PaymentProviderPickerFlowModelComposer {
    
    func compose(
        with mix: MultiElementArray<SegmentedOperatorProvider>,
        qrCode: QRCode,
        qrMapping: QRMapping
    ) -> SegmentedPaymentProviderPickerFlowModel {
        
        return .init(
            initialState: .init(content: makeContent(mix, qrCode, qrMapping)),
            factory: makeFactory(),
            scheduler: scheduler
        )
    }
}

private extension PaymentProviderPickerFlowModelComposer {
    
    func makeContent(
        _ mix: MultiElementArray<SegmentedOperatorProvider>,
        _ qrCode: QRCode,
        _ qrMapping: QRMapping
    ) -> SegmentedPaymentProviderPickerFlowState.Content {
        
        let reducer = PaymentProviderPickerReducer<SegmentedOperatorProvider>()
        let effectHandler = PaymentProviderPickerEffectHandler<SegmentedOperatorProvider>()
        
        return .init(
            initialState: .init(
                segments: .init(
                    with: mix.elements,
                    sortingSegmentsBy: \.title,
                    sortingItemsBy: \.title
                ),
                qrCode: qrCode,
                qrMapping: qrMapping
            ),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            predicate: ==,
            scheduler: scheduler
        )
    }
    
    func makeFactory(
    ) -> SegmentedPaymentProviderPickerFlowFactory {
        
        return .init(
            makePayByInstructionsViewModel: {
                
                return .init(
                    source: .requisites(qrCode: $0), 
                    model: self.model,
                    closeAction: $1
                )
            },
            makePaymentsViewModel: {
                
                return .init(
                    source: $0.source($1),
                    model: self.model,
                    closeAction: $2
                )
            },
            makeServicePickerFlowModel: makeServicePickerFlowModel
        )
    }
}

extension SegmentedOperatorProvider: Segmentable {
    
    var segmentTitle: String { segment }
}

extension SegmentedOperatorProvider {
    
    var segment: String {
        
        switch self {
        case let .operator(data):
            return data.segment
            
        case let .provider(provider):
            return provider.segment
        }
    }
    
    var title: String {
        
        switch self {
        case let .operator(data):
            return data.origin.title
            
        case let .provider(provider):
            return provider.origin.title
        }
    }
}

private extension SegmentedOperatorData {
    
    func source(
        _ qrCode: QRCode
    ) -> Payments.Operation.Source {
        
        guard let source = origin.serviceSource(matching: qrCode)
        else { return .requisites(qrCode: qrCode) }
        
        return source
    }
}
