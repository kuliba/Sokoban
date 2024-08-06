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
        let amount = digest.amount
        let currency = digest.core?.currency
        
        var formattedAmount = amount.map { "\($0)" } ?? ""
        
#warning("look into model to extract currency symbol")
        if let currency {
            formattedAmount += " \(currency)"
            _ = self
        }
        
        return formattedAmount
    }
}
