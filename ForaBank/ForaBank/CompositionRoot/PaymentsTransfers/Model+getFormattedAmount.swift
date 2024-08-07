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
        
        guard let debitAmount = context.debitAmount,
              let currency = context.currency
        else { return nil }
        
        return formatted(debitAmount, with: currency)
    }
}

extension AnywayPaymentContext {
    
    var debitAmount: Decimal? { info?.debitAmount }
    var currency: String? { info?.currency }
    
    private var info: AnywayElement.Widget.Info? {
        
        guard case let .widget(.info(info)) = payment.elements.first(matching: .widgetID(.info))
        else { return nil }
        
        return info
    }
}
