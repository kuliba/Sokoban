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
        _ processingFlag: ProcessingFlag,
        _ paymentsTransfersFlag: PaymentsTransfersFlag
    ) -> PaymentsTransfersFactory.MakeTemplates {
        
        switch paymentsTransfersFlag.rawValue {
        case .active:
            return { _ in nil }
            
        case .inactive:
            return { [weak self] in
                
                self?.makeTemplates(processingFlag, paymentsTransfersFlag, closeAction: $0)
            }
        }
    }
}

extension RootViewModelFactory {
    
    typealias Templates = TemplatesListFlowModel<TemplatesListViewModel, AnywayFlowModel>

    @inlinable
    func makeTemplates(
        _ processingFlag: ProcessingFlag,
        _ paymentsTransfersFlag: PaymentsTransfersFlag,
        closeAction: @escaping () -> Void
    ) -> Templates {
        
        let templatesComposer = makeTemplatesComposer(
            processingFlag: processingFlag,
            paymentsTransfersFlag: paymentsTransfersFlag
        )
        
        return templatesComposer.compose(dismiss: closeAction)
    }
}

extension RootViewModelFactory {
    
    @inlinable
    func makeTemplatesComposer(
        processingFlag: ProcessingFlag,
        paymentsTransfersFlag: PaymentsTransfersFlag
    ) -> TemplatesListFlowModelComposer {
        
        let composer = TemplatesListFlowEffectHandlerMicroServicesComposer(
            initiatePayment: initiatePaymentFromTemplate(template:completion:),
            makeLegacyPayment: makeLegacyTemplatePayment,
            makeTemplatesListViewModel: { [makeTemplates] in makeTemplates(processingFlag, $0)},
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

extension RootViewModelFactory {
    
    @inlinable
    func makeTemplates(
        _ processingFlag: ProcessingFlag,
        _ dismiss: @escaping () -> Void
    ) -> TemplatesListViewModel {
        
        return .init(
            model,
            dismissAction: dismiss,
            updateFastAll: { [weak model] in
                
                model?.action.send(ModelAction.Products.Update.Fast.All())
            },
            makePaymentsMeToMeViewModel: { [makePaymentsMeToMeViewModel] in makePaymentsMeToMeViewModel(processingFlag, $0) }
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
