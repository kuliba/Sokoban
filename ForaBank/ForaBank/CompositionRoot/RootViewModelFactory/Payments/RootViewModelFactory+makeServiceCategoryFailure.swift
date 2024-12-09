//
//  RootViewModelFactory+makeServiceCategoryFailure.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.12.2024.
//

import Combine

extension RootViewModelFactory {
    
    @inlinable
    func makeServiceCategoryFailure(
        categoryType: ServiceCategory.CategoryType
    ) -> ServiceCategoryFailureDomain.Binder {
        
        compose(
            getNavigation: getNavigation,
            content: categoryType,
            witnesses: .init(
                emitting: { _ in Empty() },
                dismissing: { _ in {} }
            )
        )
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
}
