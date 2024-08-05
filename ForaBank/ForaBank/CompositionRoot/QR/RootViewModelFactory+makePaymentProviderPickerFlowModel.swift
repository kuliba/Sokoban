//
//  RootViewModelFactory+makePaymentProviderPickerFlowModel.swift
//  ForaBank
//
//  Created by Igor Malyarov on 04.08.2024.
//

import CombineSchedulers
import ForaTools
import Foundation

extension RootViewModelFactory {
    
    typealias Log = (LoggerAgentLevel, LoggerAgentCategory, String, StaticString, UInt) -> Void
    
    static func makePaymentProviderPickerFlowModel(
        httpClient: HTTPClient,
        log: @escaping Log,
        model: Model,
        pageSize: Int = 50,
        utilitiesPaymentsFlag: UtilitiesPaymentsFlag,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) -> (MultiElementArray<SegmentedOperatorProvider>, QRCode) -> PaymentProviderPickerFlowModel {
        
        let transactionModelComposer = AnywayTransactionViewModelComposer(
            flag: utilitiesPaymentsFlag,
            model: model,
            httpClient: httpClient,
            log: log,
            scheduler: scheduler
        )
        let anywayComposer = AnywayFlowComposer(
            composer: transactionModelComposer,
            model: model,
            scheduler: scheduler
        )
        let loaderComposer = UtilityPaymentOperatorLoaderComposer(
            flag: utilitiesPaymentsFlag.optionOrStub,
            model: model,
            pageSize: pageSize
        )
        let loadOperators = loaderComposer.loadOperators(completion:)
        let nanoComposer = UtilityPaymentNanoServicesComposer(
            flag: utilitiesPaymentsFlag,
            model: model,
            httpClient: httpClient,
            log: log,
            loadOperators: loadOperators
        )
        let servicesModelComposer = PaymentsServicesViewModelComposer(model: model)
        let utilityMicroServicesComposer = UtilityPrepaymentFlowMicroServicesComposer(
            flag: utilitiesPaymentsFlag.rawValue,
            nanoServices: nanoComposer.compose(),
            makeLegacyPaymentsServicesViewModel: servicesModelComposer.compose(payload:)
        )
        let pickerNanoServicesComposer = UtilityPaymentNanoServicesComposer(
            flag: utilitiesPaymentsFlag,
            model: model,
            httpClient: httpClient,
            log: log,
            loadOperators: loadOperators
        )
        let pickerMicroServicesComposer = AsyncPickerEffectHandlerMicroServicesComposer(
            composer: utilityMicroServicesComposer,
            nanoServices: pickerNanoServicesComposer.compose()
        )
        let servicePickerComposer = AnywayServicePickerFlowModelComposer(
            makeAnywayFlowModel: anywayComposer.compose(transaction:),
            microServices: pickerMicroServicesComposer.compose(),
            model: model,
            scheduler: scheduler
        )
        let pickerFlowComposer = PaymentProviderPickerFlowModelComposer(
            makeServicePickerFlowModel: servicePickerComposer.compose,
            model: model,
            scheduler: scheduler
        )
        
        return pickerFlowComposer.compose(with:qrCode:)
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
