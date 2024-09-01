//
//  PaymentProviderPickerFlowEffectHandlerMicroServicesComposer.swift
//
//
//  Created by Igor Malyarov on 01.09.2024.
//

import ForaTools

public final class PaymentProviderPickerFlowEffectHandlerMicroServicesComposer<Latest, Payment, PayByInstructions, Provider, Service> {
    
    private let nanoServices: NanoServices
    
    public init(
        nanoServices: NanoServices
    ) {
        self.nanoServices = nanoServices
    }
    
    public typealias NanoServices = PaymentProviderPickerFlowEffectHandlerNanoServices<Latest, Payment, PayByInstructions, Provider, Service>
}

public extension PaymentProviderPickerFlowEffectHandlerMicroServicesComposer {
    
    func compose() -> MicroServices {
        
        return .init(
            initiatePayment: initiatePayment,
            makePayByInstructions: nanoServices.makePayByInstructions,
            processProvider: processProvider
        )
    }
    
    typealias MicroServices = PaymentProviderPickerFlowEffectHandlerMicroServices<Latest, Payment, PayByInstructions, Provider, Service>
}

// MARK: - initiatePayment

private extension PaymentProviderPickerFlowEffectHandlerMicroServicesComposer {
    
    func initiatePayment(
        latest: Latest,
        completion: @escaping (Result<Payment, ServiceFailure>) -> Void
    ) {
        nanoServices.initiatePayment(.latest(latest), completion)
    }
}

// MARK: - processProvider

private extension PaymentProviderPickerFlowEffectHandlerMicroServicesComposer {
    
    func processProvider(
        provider: Provider,
        completion: @escaping (ProcessProviderResult<Payment, Service>) -> Void
    ) {
        nanoServices.getServiceCategoryList(provider) { [weak self] in
            
            guard let self else { return }
            
            switch $0 {
            case .failure:
                completion(.servicesFailure)
                
            case let .success(services):
                processServices(services, completion)
            }
        }
    }
    
    private func processServices(
        _ services: [Service],
        _ completion: @escaping (ProcessProviderResult<Payment, Service>) -> Void
    ) {
        let service = services.first
        let services = MultiElementArray(services)
        
        switch (service, services) {
        case (nil, _):
            completion(.servicesFailure)
            
        case let (_, .some(services)):
            completion(.services(services))
            
        case let (.some(service), _):
            initiatePayment(with: service, completion)
        }
    }
    
    private func initiatePayment(
        with service: Service,
        _ completion: @escaping (ProcessProviderResult<Payment, Service>) -> Void
    ) {
        nanoServices.initiatePayment(.service(service)) {
            
            switch $0 {
            case let .failure(serviceFailure):
                completion(.initiatePaymentResult(.failure(serviceFailure)))
                
            case let .success(payment):
                completion(.initiatePaymentResult(.success(payment)))
            }
        }
    }
}
