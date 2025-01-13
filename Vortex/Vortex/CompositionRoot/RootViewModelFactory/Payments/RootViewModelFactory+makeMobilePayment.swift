//
//  RootViewModelFactory+makeMobilePayment.swift
//  Vortex
//
//  Created by Igor Malyarov on 22.11.2024.
//

extension RootViewModelFactory {
    
    @inlinable
    func makeMobilePayment() -> ClosePaymentsViewModelWrapper {
        
        return .init(
            model: model,
            service: .mobileConnection,
            scheduler: schedulers.main
        )
    }
}
