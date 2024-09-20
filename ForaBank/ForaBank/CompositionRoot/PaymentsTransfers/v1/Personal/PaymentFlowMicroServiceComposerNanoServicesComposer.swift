//
//  PaymentFlowMicroServiceComposerNanoServicesComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 20.09.2024.
//

import PayHub

final class PaymentFlowMicroServiceComposerNanoServicesComposer {
    
    let standardNanoServices: StandardNanoServices
    
    init(
        standardNanoServices: StandardNanoServices
    ) {
        self.standardNanoServices = standardNanoServices
    }
    
    typealias StandardNanoServices = StandardSelectedCategoryDestinationNanoServices<ServiceCategory, Latest, Operator, SelectedCategoryStub, FailedPaymentProviderPickerStub>
}

extension PaymentFlowMicroServiceComposerNanoServicesComposer {
    
    func compose(category: ServiceCategory) -> NanoServices {
        
        let standardFlowComposer = StandardSelectedCategoryDestinationMicroServiceComposer(
            nanoServices: standardNanoServices
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
    
    typealias NanoServices = PaymentFlowMicroServiceComposerNanoServices<MobileBinderStub, QRBinderStub, StandardSelectedCategoryDestination, TaxBinderStub, TransportBinderStub>
}
