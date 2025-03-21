//
//  RootViewModelFactory+makePaymentsMeToMeViewModel.swift
//  Vortex
//
//  Created by Andryusina Nataly on 19.03.2025.
//

extension RootViewModelFactory {
    
    @inlinable
    func makePaymentsMeToMeViewModel(
        _ processingFlag: ProcessingFlag,
        _ mode: PaymentsMeToMeViewModel.Mode
    ) -> PaymentsMeToMeViewModel? {
        .init(
            model,
            mode: mode,
            successViewModelFactory: makeSuccessViewModelFactory(processingFlag)
        )
    }
}
