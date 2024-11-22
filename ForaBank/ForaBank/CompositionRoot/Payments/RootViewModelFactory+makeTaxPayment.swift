//
//  RootViewModelFactory+makeTaxPayment.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.11.2024.
//

extension RootViewModelFactory {
    
    @inlinable
    func makeTaxPayment() -> ClosePaymentsViewModelWrapper {
        
        return .init(
            model: model,
            category: .taxes,
            scheduler: schedulers.main
        )
    }
}
