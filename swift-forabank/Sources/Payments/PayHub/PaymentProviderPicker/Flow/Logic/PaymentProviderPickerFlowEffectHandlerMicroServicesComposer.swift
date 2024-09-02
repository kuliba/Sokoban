//
//  PaymentProviderPickerFlowEffectHandlerMicroServicesComposer.swift
//
//
//  Created by Igor Malyarov on 01.09.2024.
//

import ForaTools

public final class PaymentProviderPickerFlowEffectHandlerMicroServicesComposer<Latest, PayByInstructions, Payment, Provider, Service, ServicesPicker, ServicesFailure> {
    
    private let nanoServices: NanoServices
    
    public init(
        nanoServices: NanoServices
    ) {
        self.nanoServices = nanoServices
    }
    
    public typealias NanoServices = PaymentProviderPickerFlowEffectHandlerNanoServices<Latest, PayByInstructions, Payment, Provider, Service, ServicesPicker, ServicesFailure>
}

public extension PaymentProviderPickerFlowEffectHandlerMicroServicesComposer {
    
    func compose() -> MicroServices {
        
        return .init(
            initiatePayment: initiatePayment,
            makePayByInstructions: nanoServices.makePayByInstructions,
            processProvider: processProvider
        )
    }
    
    typealias MicroServices = PaymentProviderPickerFlowEffectHandlerMicroServices<Latest, PayByInstructions, Payment, Provider, ServicesPicker, ServicesFailure>
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
        completion: @escaping (MicroServices.ProcessResult) -> Void
    ) {
        nanoServices.getServiceCategoryList(provider) { [weak self] in
            
            guard let self else { return }
            
            switch $0 {
            case .failure:
                nanoServices.makeServicesFailure { completion(.servicesResult(.servicesFailure($0))) }
                
            case let .success(services):
                processServices(services, completion)
            }
        }
    }
    
    private func processServices(
        _ services: [Service],
        _ completion: @escaping (MicroServices.ProcessResult) -> Void
    ) {
        let service = services.first
        let services = MultiElementArray(services)
        
        switch (service, services) {
        case (nil, _):
            nanoServices.makeServicesFailure { completion(.servicesResult(.servicesFailure($0))) }
            
        case let (_, .some(services)):
            nanoServices.makeServicePicker(services) { completion(.servicesResult(.servicePicker($0))) }
            
        case let (.some(service), _):
            initiatePayment(with: service, completion)
        }
    }
    
    private func initiatePayment(
        with service: Service,
        _ completion: @escaping (MicroServices.ProcessResult) -> Void
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
