//
//  RootViewModelFactory+makeTemplatesComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 10.08.2024.
//

import CombineSchedulers
import Foundation

extension RootViewModelFactory {
    
    @inlinable
    func makeTemplatesComposer(
        paymentsTransfersFlag: PaymentsTransfersFlag
    ) -> TemplatesListFlowModelComposer {
        
        let composer = TemplatesListFlowEffectHandlerMicroServicesComposer(
            initiatePayment: initiatePaymentFromTemplate(template:completion:),
            makeLegacyPayment: makeLegacyTemplatePayment,
            paymentsTransfersFlag: paymentsTransfersFlag
        )
        
        return .init(
            model: model,
            microServices: composer.compose(),
            scheduler: schedulers.main
        )
    }
}

private extension PaymentTemplateData {
    
    var puref: String? {
        
        let asTransferAnywayData = parameterList
            .compactMap { $0 as? TransferAnywayData }
        
        return asTransferAnywayData.compactMap(\.puref).first
    }
}
