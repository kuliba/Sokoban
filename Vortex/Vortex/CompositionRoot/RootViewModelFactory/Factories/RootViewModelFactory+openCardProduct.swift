//
//  RootViewModelFactory+openCardProduct.swift
//  Vortex
//
//  Created by Igor Malyarov on 06.02.2025.
//

extension RootViewModelFactory {
    
    @inlinable
    func openCardProduct(
        notify: @escaping () -> Void
    ) -> OpenProduct.OpenCard {
        
        return composeBinder(
            content: (),
            delayProvider: delayProvider,
            getNavigation: getNavigation,
            witnesses: witnesses()
        )
    }
    
    @inlinable
    func delayProvider(
        navigation: OpenCardDomain.Navigation
    ) -> Delay {
        
    }
    
    @inlinable
    func getNavigation(
        select: OpenCardDomain.Select,
        notify: @escaping OpenCardDomain.Notify,
        completion: @escaping (OpenCardDomain.Navigation) -> Void
    ) {
        
    }
    
    @inlinable
    func witnesses() -> OpenCardDomain.Witnesses {
        
        return .empty // TODO: replace with (a) emitting failure (alert/informer) (b) dismissing failure
    }
}
