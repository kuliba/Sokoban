//
//  RootViewModelFactory+makeMobilePayment.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.11.2024.
//

extension RootViewModelFactory {
    
    func makeMobilePayment() -> ClosePaymentsViewModelWrapper {
        
        return .init(
            model: model,
            service: .mobileConnection,
            scheduler: schedulers.main
        )
    }
}
