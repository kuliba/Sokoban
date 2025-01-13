//
//  RootViewModelFactory+makeProviderServicePicker.swift
//  Vortex
//
//  Created by Igor Malyarov on 29.12.2024.
//

import Combine
import VortexTools

extension RootViewModelFactory {
    
    @inlinable
    func makeProviderServicePicker(
        provider: UtilityPaymentOperator,
        services: MultiElementArray<UtilityService>
    ) -> ProviderServicePickerDomain.Binder {
        
        let content = ProviderServicePickerDomain.Content(provider: provider, services: services)
        
        return composeBinder(
            content: content,
            delayProvider: delayProvider,
            getNavigation: getProviderServicePickerNavigation,
            witnesses: .init(emitting: emitting, dismissing: dismissing)
        )
    }
    
    @inlinable
    func delayProvider(
        navigation: ProviderServicePickerDomain.Navigation
    ) -> Delay {
        
        switch navigation {
        case .outside: return .milliseconds(100)
        case .failure: return settings.delay
        case .payment: return settings.delay
        }
    }
    
    @inlinable
    func getProviderServicePickerNavigation(
        select: ProviderServicePickerDomain.Select,
        notify: @escaping ProviderServicePickerDomain.Notify,
        completion: @escaping (ProviderServicePickerDomain.Navigation) -> Void
    ) {
        switch select {
        case let .outside(outside):
            completion(.outside(outside))
            
        case let .service(servicePayload):
            initiateAnywayPayment(
                payload: servicePayload.source
            ) { [weak self] in
                
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
    
    @inlinable
    func emitting(
        content: ProviderServicePickerDomain.Content
    ) -> some Publisher<FlowEvent<ProviderServicePickerDomain.Select, Never>, Never> {
        
        Empty()
    }
    
    @inlinable
    func dismissing(
        content: ProviderServicePickerDomain.Content
    ) -> () -> Void {
        
        return { }
    }
}

// MARK: - Adapters

private extension ProviderServicePickerDomain.Select.ServicePayload {
    
    var source: AnywayPaymentSourceParser.Source {
        
        if item.isOneOf {
            return .oneOf(item.service, `operator`.provider)
        } else {
            return .single(item.service, `operator`.provider)
        }
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
