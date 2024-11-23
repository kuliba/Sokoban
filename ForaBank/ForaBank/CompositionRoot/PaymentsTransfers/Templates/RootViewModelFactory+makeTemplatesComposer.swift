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
        
        let anywayFlowComposer = makeAnywayFlowComposer()
        let microServicesComposer = TemplatesListFlowEffectHandlerMicroServicesComposer<PaymentsViewModel, AnywayFlowModel>(
            initiatePayment: initiatePaymentFromTemplate(using: anywayFlowComposer),
            makeLegacyPayment: { payload in
                
                let (template, close) = payload
                
                return PaymentsViewModel(
                    source: .template(template.id),
                    model: self.model,
                    closeAction: close
                )
            },
            paymentsTransfersFlag: paymentsTransfersFlag
        )
        
        return .init(
            makeAnywayFlowModel: anywayFlowComposer.compose,
            model: model,
            microServices: microServicesComposer.compose(),
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
