//
//  RootViewModelFactory+getPaymentsTransfersPersonalNavigation.swift
//  ForaBank
//
//  Created by Igor Malyarov on 01.12.2024.
//

extension RootViewModelFactory {
    
    @inlinable
    func getPaymentsTransfersPersonalNavigation(
        select: PaymentsTransfersPersonalDomain.Select,
        notify: @escaping PaymentsTransfersPersonalDomain.Notify,
        completion: @escaping (PaymentsTransfersPersonalDomain.Navigation) -> Void
    ) {
        completion(select)
    }
}
