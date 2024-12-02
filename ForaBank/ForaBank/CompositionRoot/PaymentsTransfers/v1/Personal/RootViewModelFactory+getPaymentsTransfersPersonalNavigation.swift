//
//  RootViewModelFactory+getPaymentsTransfersPersonalNavigation.swift
//  ForaBank
//
//  Created by Igor Malyarov on 01.12.2024.
//

extension RootViewModelFactory {
    
    func getPaymentsTransfersPersonalNavigation(
        select: PaymentsTransfersPersonalDomain.Select,
        notify: @escaping PaymentsTransfersPersonalDomain.Notify,
        completion: @escaping (PaymentsTransfersPersonalDomain.Navigation) -> Void
    ) {
        switch select {
        case let.outside(outside):
            switch outside {
            case .templates:
                completion(.templates)
                
            case .userAccount:
                completion(.userAccount)
                
            default:
                break
            }
        }
    }
}
