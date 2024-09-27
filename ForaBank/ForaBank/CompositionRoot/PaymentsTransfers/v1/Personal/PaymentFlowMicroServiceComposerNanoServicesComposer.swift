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
        
        let composer = StandardSelectedCategoryDestinationMicroServiceComposer(
            nanoServices: standardNanoServices
        )
        let standardMicroService = composer.compose()
        
        return .init(
            makeMobile: {
                
                $0(.success(.init(
                    model: self.model,
                    service: .mobileConnection,
                    scheduler: self.scheduler
                )))
            },
            makeQR: { $0(.success(.init())) },
            makeStandard: { completion in
                
                standardMicroService.makeDestination(category) {
                    
                    completion(.success($0))
                }
            },
            makeTax: { $0(.success(.init())) },
            makeTransport: makeTransport
        )
    }
    
    typealias NanoServices = PaymentFlowMicroServiceComposerNanoServices<ClosePaymentsViewModelWrapper, QRBinderStub, StandardSelectedCategoryDestination, TaxBinderStub, TransportPaymentsViewModel, SelectedCategoryFailure>
}

private extension PaymentFlowMicroServiceComposerNanoServicesComposer {
    
    typealias TransportCompletion = (Result<TransportPaymentsViewModel, SelectedCategoryFailure>) -> Void
    
    func makeTransport(_ completion: @escaping TransportCompletion) {
        
        guard let transport = self.makeTransport() else {
            
            return completion(.failure(.init(
                id: .init(),
                message: "Ошибка создания транспортных платежей"
            )))
        }
        
        completion(.success(transport))
    }
    
    func makeTransport() -> TransportPaymentsViewModel? {
        
        model.makeTransportPaymentsViewModel(type: .transport)
    }
}
