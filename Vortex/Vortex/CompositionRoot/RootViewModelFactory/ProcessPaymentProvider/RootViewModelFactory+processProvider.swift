//
//  RootViewModelFactory+processProvider.swift
//  Vortex
//
//  Created by Igor Malyarov on 29.12.2024.
//

import RemoteServices
import VortexTools

extension RootViewModelFactory {
    
    typealias ProcessPaymentProviderDomain<Result> = Vortex.ProcessPaymentProviderDomain<UtilityPaymentOperator, ServicePickerItem, Result>
    
    func processProvider<Result>(
        payload: ProcessPaymentProviderDomain<Result>.Payload,
        processService: @escaping (ServicePickerItem, @escaping (Result) -> Void) -> Void,
        completion: @escaping (ProcessPaymentProviderDomain<Result>.Response) -> Void
    ) {
        loadServices(for: payload.getServicesForPayload) {
            
            switch ($0.first, MultiElementArray($0)) {
            case (nil, _):
                completion(.operatorFailure(payload))
                
            case let (.some(service), nil):
                processService(service) { completion(.startPayment($0)) }
                
            case let (_, .some(services)):
                completion(.services(services, for: payload))
            }
        }
    }
}

// MARK: - Adapters

private extension UtilityPaymentOperator {
    
    var getServicesForPayload: RootViewModelFactory.GetServicesForPayload {
        
        return .init(operatorID: id, type: type)
    }
}
