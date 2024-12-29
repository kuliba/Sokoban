//
//  RootViewModelFactory+makeProviderServicePicker.swift
//  Vortex
//
//  Created by Igor Malyarov on 29.12.2024.
//

import Combine
import VortexTools

extension RootViewModelFactory {
    
    func makeProviderServicePicker(
        provider: UtilityPaymentOperator,
        services: MultiElementArray<UtilityService>
    ) -> ProviderServicePickerDomain.Binder {
        
        compose(
            getNavigation: getProviderServicePickerNavigation,
            content: .init(provider: provider, services: services),
            witnesses: .init(
                emitting: { _ in Empty().eraseToAnyPublisher() },
                dismissing: { _ in {}}
            )
        )
    }
    
    func getProviderServicePickerNavigation(
        select: ProviderServicePickerDomain.Select,
        notify: @escaping ProviderServicePickerDomain.Notify,
        completion: @escaping (ProviderServicePickerDomain.Navigation) -> Void
    ) {
        switch select {
        case let .outside(outside):
            completion(.outside(outside))
            
        case let .service(servicePayload):
            process(payload: servicePayload.payload) { [weak self] in
                
                guard let self else { return }
                
                switch $0 {
                case let .failure(failure):
                    completion(.failure(failure))
                    
                case let .success(anywayFlowModel):
                    completion(.payment(.init(
                        model: anywayFlowModel,
                        cancellable: bind(anywayFlowModel, to: notify)
                    )))
                }
            }
        }
    }
    
    func bind(
        _ model: AnywayFlowModel,
        to notify: @escaping ProviderServicePickerDomain.Notify
    ) -> AnyCancellable {
        
        model.$state
            .compactMap(\.outside?.event)
            .sink { notify(.select(.outside($0))) }
    }
}

private extension ProviderServicePickerDomain.Select.ServicePayload {
    
    var payload: RootViewModelFactory.ProcessServicePayload {
        
        return .init(item: item, operator: `operator`.provider)
    }
}

private extension UtilityPaymentOperator {
    
    var provider: UtilityPaymentProvider {
        
        return .init(id: id, icon: icon, inn: inn, title: title, type: type)
    }
}

private extension AnywayFlowState.Status.Outside {
    
    var event: ProviderServicePickerDomain.Outside {
        
        switch self {
        case .main:     return .main
        case .payments: return .payments
        }
    }
}
