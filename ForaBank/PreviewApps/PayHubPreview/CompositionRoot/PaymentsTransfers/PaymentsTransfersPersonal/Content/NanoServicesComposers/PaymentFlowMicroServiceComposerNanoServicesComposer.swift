//
//  PaymentFlowMicroServiceComposerNanoServicesComposer.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 03.09.2024.
//

import PayHub

final class PaymentFlowMicroServiceComposerNanoServicesComposer {}

extension PaymentFlowMicroServiceComposerNanoServicesComposer {
 
    func compose(category: ServiceCategory) -> NanoServices {
        
        let standardNanoServicesComposer = StandardSelectedCategoryDestinationNanoServicesComposer()
        let standardFlowComposer = StandardSelectedCategoryDestinationMicroServiceComposer(
            nanoServices: standardNanoServicesComposer.compose(category: category)
        )
        let standardMicroService = standardFlowComposer.compose()

        return .init(
            makeMobile: { $0(MobileBinderStub()) },
            makeQR: { $0(QRBinderStub()) },
            makeStandard: { standardMicroService.makeDestination(category, $0) },
            makeTax: { $0(TaxBinderStub()) },
            makeTransport: { $0(TransportBinderStub()) }
        )
    }
 
    typealias NanoServices = PaymentFlowMicroServiceComposerNanoServices<MobileBinderStub, QRBinderStub, Result<SelectedCategoryStub, Error>, TaxBinderStub, TransportBinderStub>
}
