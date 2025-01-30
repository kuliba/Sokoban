//
//  RootViewModelFactory+makeOpenProductFlow.swift
//  Vortex
//
//  Created by Igor Malyarov on 30.01.2025.
//

import Foundation

extension RootViewModelFactory {
    
    @inlinable
    func makeOpenProductFlow() -> OpenProductDomain.Flow {
        
        // TODO: extract flow composer
        let binder: Binder<Void, OpenProductDomain.Flow> = composeBinder(
            content: (),
            delayProvider: delayProvider,
            getNavigation: getNavigation,
            witnesses: .empty
        )
        
        return binder.flow
    }
    
    @inlinable
    func delayProvider(
        navigation: OpenProductDomain.Navigation
    ) -> Delay {
        
        switch navigation {
        case .openProduct: return .milliseconds(100)
        }
    }
    
    @inlinable
    func getNavigation(
        select: OpenProductDomain.Select,
        notify: @escaping OpenProductDomain.Notify,
        completion: @escaping (OpenProductDomain.Navigation) -> Void
    ) {
        switch select {
        case .openProduct:
            completion(.openProduct(.init(
                model: .init(model, makeOpenNewProductButtons: { _ in [] }),
                cancellables: []
            )))
        }
    }
}
