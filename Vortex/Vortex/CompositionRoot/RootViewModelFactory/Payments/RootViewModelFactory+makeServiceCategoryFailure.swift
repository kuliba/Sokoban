//
//  RootViewModelFactory+makeServiceCategoryFailure.swift
//  Vortex
//
//  Created by Igor Malyarov on 09.12.2024.
//

import Combine

extension RootViewModelFactory {
    
    @inlinable
    func makeServiceCategoryFailure(
        category: ServiceCategory
    ) -> ServiceCategoryFailureDomain.Binder {
        
        return composeBinder(
            content: category,
            delayProvider: delayProvider,
            getNavigation: getNavigation,
            witnesses: .init(emitting: emitting, dismissing: dismissing)
        )
    }

    @inlinable
    func delayProvider(
        navigation: ServiceCategoryFailureDomain.Navigation
    ) -> Delay {
        
        switch navigation {
        case .detailPayment: return settings.delay
        case .scanQR:        return .milliseconds(200)
        }
    }
    
    @inlinable
    func getNavigation(
        select: ServiceCategoryFailureDomain.Select,
        notify: @escaping ServiceCategoryFailureDomain.Notify,
        completion: @escaping (ServiceCategoryFailureDomain.Navigation) -> Void
    ) {
        switch select {
        case .detailPayment:
            let node = makePaymentsNode(
                payload: .service(.requisites)
            ) {
                switch $0 {
                case .close:
                    notify(.dismiss)
                    
                case .scanQR:
                    notify(.select(.scanQR))
                }
            }
            completion(.detailPayment(node))
            
        case .scanQR:
            completion(.scanQR)
        }
    }
    
    @inlinable
    func emitting(
        content: ServiceCategoryFailureDomain.Content
    ) -> some Publisher<FlowEvent<ServiceCategoryFailureDomain.Select, Never>, Never> {
        
        Empty()
    }
    
    @inlinable
    func dismissing(
        content: ServiceCategoryFailureDomain.Content
    ) -> () -> Void {
        
        return { }
    }
}
