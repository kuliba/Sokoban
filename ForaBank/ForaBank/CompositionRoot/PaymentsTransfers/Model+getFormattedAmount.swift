//
//  Model+getFormattedAmount.swift
//  ForaBank
//
//  Created by Igor Malyarov on 06.08.2024.
//

import AnywayPaymentDomain
import Foundation

extension Model {
    
    func getFormattedAmount(
        context: AnywayPaymentContext
    ) -> String? {
        
        let digest = context.makeDigest()
        
        guard let amount = digest.amount,
              let currency = digest.core?.currency
        else { return nil }
        
        return formatted(amount, with: currency)
    }
}
