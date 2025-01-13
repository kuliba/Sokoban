//
//  RootViewModelFactory+makeTemplatesComposer.swift
//  Vortex
//
//  Created by Igor Malyarov on 10.08.2024.
//

import CombineSchedulers
import Foundation

extension RootViewModelFactory {
    
    @inlinable
    func makeMakeTemplates(
        _ paymentsTransfersFlag: PaymentsTransfersFlag
    ) -> PaymentsTransfersFactory.MakeTemplates {
        
        switch paymentsTransfersFlag.rawValue {
        case .active:
            return { _ in nil }
            
        case .inactive:
            return { [weak self] in
                
                self?.makeTemplates(paymentsTransfersFlag, closeAction: $0)
            }
        }
    }
}

extension RootViewModelFactory {
    
    typealias Templates = TemplatesListFlowModel<TemplatesListViewModel, AnywayFlowModel>

    @inlinable
    func makeTemplates(
        _ paymentsTransfersFlag: PaymentsTransfersFlag,
        closeAction: @escaping () -> Void
    ) -> Templates {
        
        let templatesComposer = makeTemplatesComposer(
            paymentsTransfersFlag: paymentsTransfersFlag
        )
        
        return templatesComposer.compose(dismiss: closeAction)
    }
}

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
    
    @inlinable
    func initiatePaymentFromTemplate(
        template: PaymentTemplateData,
        completion: @escaping (Result<AnywayFlowModel, ServiceFailureAlert.ServiceFailure>) -> Void
    ) {
        initiateAnywayPayment(payload: .template(template), completion: completion)
    }
}

private extension PaymentTemplateData {
    
    var puref: String? {
        
        let asTransferAnywayData = parameterList
            .compactMap { $0 as? TransferAnywayData }
        
        return asTransferAnywayData.compactMap(\.puref).first
    }
}
