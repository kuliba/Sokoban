//
//  RootViewModelFactory+makeSegmentedPaymentProviderPickerFlowModel.swift
//  ForaBank
//
//  Created by Igor Malyarov on 04.08.2024.
//

import CombineSchedulers
import ForaTools
import Foundation

extension RootViewModelFactory {
    
    typealias Log = (LoggerAgentLevel, LoggerAgentCategory, String, StaticString, UInt) -> Void
    
    static func makeSegmentedPaymentProviderPickerFlowModel(
        httpClient: HTTPClient,
        log: @escaping Log,
        model: Model,
        pageSize: Int = 50,
        flag: StubbedFeatureFlag.Option,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) -> (MultiElementArray<SegmentedOperatorProvider>, QRCode, QRMapping) -> SegmentedPaymentProviderPickerFlowModel {
        
        let servicePickerComposer = makeAnywayServicePickerFlowModelComposer(
            httpClient: httpClient,
            log: log,
            model: model,
            flag: flag,
            scheduler: scheduler
        )
        
        let pickerFlowComposer = PaymentProviderPickerFlowModelComposer(
            makeServicePickerFlowModel: servicePickerComposer.compose,
            model: model,
            scheduler: scheduler
        )
        
        return pickerFlowComposer.compose
    }
}

extension UtilityPaymentOperatorLoaderComposer {
    
    func loadOperators(
        completion: @escaping ([UtilityPaymentOperator]) -> Void
    ) {
        let load = compose()
        
        load(.init()) { completion($0); _ = load }
    }
}
