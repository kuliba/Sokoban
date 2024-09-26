//
//  PaymentFlowMicroServiceComposerNanoServicesComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 20.09.2024.
//

import Combine
import CombineSchedulers
import Foundation
import PayHub

final class PaymentFlowMicroServiceComposerNanoServicesComposer {
    
    private let model: Model
    private let standardNanoServices: StandardNanoServices
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    init(
        model: Model,
        standardNanoServices: StandardNanoServices,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.model = model
        self.standardNanoServices = standardNanoServices
        self.scheduler = scheduler
    }
    
    typealias Operator = PaymentServiceOperator
    typealias StandardNanoServices = StandardSelectedCategoryDestinationNanoServices<ServiceCategory, Latest, Operator, PaymentProviderPicker.Binder, FailedPaymentProviderPickerStub>
}

extension PaymentFlowMicroServiceComposerNanoServicesComposer {
    
    func compose(category: ServiceCategory) -> NanoServices {
        
        let standardFlowComposer = StandardSelectedCategoryDestinationMicroServiceComposer(
            nanoServices: standardNanoServices
        )
        let standardMicroService = standardFlowComposer.compose()
        
        return .init(
            makeMobile: {
                
                $0(.init(
                    model: self.model,
                    service: .mobileConnection,
                    scheduler: self.scheduler
                ))
            },
            makeQR: { $0(QRBinderStub()) },
            makeStandard: { standardMicroService.makeDestination(category, $0) },
            makeTax: { $0(TaxBinderStub()) },
            makeTransport: { $0(TransportBinderStub()) }
        )
    }
    
    typealias NanoServices = PaymentFlowMicroServiceComposerNanoServices<ClosePaymentsViewModelWrapper, QRBinderStub, StandardSelectedCategoryDestination, TaxBinderStub, TransportBinderStub>
}
