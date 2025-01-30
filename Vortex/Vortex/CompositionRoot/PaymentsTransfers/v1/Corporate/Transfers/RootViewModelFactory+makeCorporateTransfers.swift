//
//  RootViewModelFactory+makeCorporateTransfers.swift
//  Vortex
//
//  Created by Igor Malyarov on 30.01.2025.
//

import Foundation

extension RootViewModelFactory {
    
    @inlinable
    func makeCorporateTransfers(
    ) -> PaymentsTransfersCorporateTransfersDomain.Binder {
        
        composeBinder(
            content: (),
            delayProvider: delayProvider,
            getNavigation: getNavigation,
            witnesses: .empty
        )
    }
    
    @inlinable
    func delayProvider(
        navigation: PaymentsTransfersCorporateTransfersDomain.Navigation
    ) -> Delay {
        
        switch navigation {
        case .meToMe:      return .milliseconds(100)
        case .openProduct: return .milliseconds(100)
        }
    }
    
    @inlinable
    func getNavigation(
        select: PaymentsTransfersCorporateTransfersDomain.Select,
        notify: @escaping PaymentsTransfersCorporateTransfersDomain.Notify,
        completion: @escaping (PaymentsTransfersCorporateTransfersDomain.Navigation) -> Void
    ) {
        switch select {
        case .meToMe:
            completion(.meToMe(""))
            
        case .openProduct:
            completion(.openProduct(""))
        }
    }
}
