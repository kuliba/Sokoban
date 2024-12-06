//
//  RootViewModelFactory+getPaymentsTransfersCorporateNavigation.swift
//  Vortex
//
//  Created by Igor Malyarov on 01.12.2024.
//

extension RootViewModelFactory {
    
    func getPaymentsTransfersCorporateNavigation(
        select: PaymentsTransfersCorporateDomain.Select,
        notify: @escaping PaymentsTransfersCorporateDomain.Notify,
        completion: @escaping (PaymentsTransfersCorporateDomain.Navigation) -> Void
    ) {
        switch select {
        case .userAccount:
            completion(.userAccount)
        }
    }
}
