//
//  PaymentProviderPickerFlowEffectHandlerMicroServicesComposer.swift
//
//
//  Created by Igor Malyarov on 01.09.2024.
//

import ForaTools

public final class PaymentProviderPickerFlowEffectHandlerMicroServicesComposer<DetailPayment, Latest, Payment, Provider, Service, ServicePicker, ServicesFailure> {
    
    private let nanoServices: NanoServices
    
    public init(
        nanoServices: NanoServices
    ) {
        self.nanoServices = nanoServices
    }
    
    public typealias NanoServices = PaymentProviderPickerFlowEffectHandlerNanoServices<DetailPayment, Latest, Payment, Provider, Service, ServicePicker, ServicesFailure>
}

public extension PaymentProviderPickerFlowEffectHandlerMicroServicesComposer {
    
    func compose() -> MicroServices {
        
        return .init(
            initiatePayment: initiatePayment,
            makeDetailPayment: makeDetailPayment,
            processProvider: processProvider
        )
    }
    
    typealias Destination = PaymentProviderPickerDestination<DetailPayment, Payment, ServicePicker, ServicesFailure>
    typealias MicroServices = PaymentProviderPickerFlowEffectHandlerMicroServices<Destination, Latest, Provider>
}

// MARK: - initiatePayment

private extension PaymentProviderPickerFlowEffectHandlerMicroServicesComposer {
    
    func initiatePayment(
        latest: Latest,
        completion: @escaping (Destination) -> Void
    ) {
        nanoServices.initiatePayment(.latest(latest)) {
            
            switch $0 {
            case let .failure(backendFailure):
                completion(.backendFailure(backendFailure))
                
            case let .success(payment):
                completion(.payment(payment))
            }
        }
    }
}

// MARK: - makeDetailPayment

private extension PaymentProviderPickerFlowEffectHandlerMicroServicesComposer {
    
    func makeDetailPayment(
        completion: @escaping (Destination) -> Void
    ) {
        nanoServices.makeDetailPayment {
            
            completion(.detailPayment($0))
        }
    }
}

// MARK: - processProvider

private extension PaymentProviderPickerFlowEffectHandlerMicroServicesComposer {
    
    func processProvider(
        provider: Provider,
        completion: @escaping (Destination) -> Void
    ) {
        nanoServices.getServiceCategoryList(provider) { [weak self] in
            
            guard let self else { return }
            
            switch $0 {
            case .failure:
                nanoServices.makeServicesFailure {
                    
                    completion(.servicesFailure($0))
                }
                
            case let .success(services):
                processServices(services, completion)
            }
        }
    }
    
    private func processServices(
        _ services: [Service],
        _ completion: @escaping (Destination) -> Void
    ) {
        let service = services.first
        let services = MultiElementArray(services)
        
        switch (service, services) {
        case (nil, _):
            nanoServices.makeServicesFailure {
                
                completion(.servicesFailure($0))
            }
            
        case let (_, .some(services)):
            nanoServices.makeServicePicker(services) {
                
                completion(.servicePicker($0))
            }
            
        case let (.some(service), _):
            initiatePayment(with: service, completion)
        }
    }
    
    private func initiatePayment(
        with service: Service,
        _ completion: @escaping (Destination) -> Void
    ) {
        nanoServices.initiatePayment(.service(service)) {
            
            switch $0 {
            case let .failure(backendFailure):
                completion(.backendFailure(backendFailure))
                
            case let .success(payment):
                completion(.payment(payment))
            }
        }
    }
}
