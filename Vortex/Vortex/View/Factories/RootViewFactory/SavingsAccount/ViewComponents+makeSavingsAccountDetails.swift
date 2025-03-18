//
//  ViewComponents+makeSavingsAccountDetails.swift
//  Vortex
//
//  Created by Andryusina Nataly on 13.03.2025.
//

import SavingsAccount

extension ViewComponents {
    
    func makeSavingsAccountDetails(
        amountToString: @escaping SavingsAccountDetailsView.AmountToString,
        state: SavingsAccountDetailsState,
        event: @escaping (SavingsAccountDetailsEvent) -> Void,
        config: SavingsAccountDetailsConfig = .iVortex
    ) -> SavingsAccountDetailsView {
        
        .init(
            amountToString: amountToString,
            state: state,
            event: event,
            config: config
        )
    }
}
