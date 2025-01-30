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
    
    @inlinable
    func makeMobilePayment(
        closeAction: @escaping () -> Void
    ) -> PaymentsViewModel {
        
        return .init(
            model,
            service: .mobileConnection,
            closeAction: closeAction
        )
    }
}
