//
//  OrderSavingsAccountState.swift
//  
//
//  Created by Andryusina Nataly on 25.11.2024.
//

import SwiftUI
import AmountComponent

public struct OrderSavingsAccountState: Equatable {
    
    let formatter: NumberFormatter
    let status: Status
    var amountValue: Decimal
    var consent: Bool = true
    var isShowingOTP: Bool = false
    

    public init(
        formatter: NumberFormatter,
        status: Status,
        amountValue: Decimal = 0
    ) {
        self.formatter = formatter
        self.status = status
        self.amountValue = amountValue
    }
}

public extension OrderSavingsAccountState {
    
    enum Status: Equatable {
        
        case inflight
        case result(OrderSavingsAccount)
    }
}

extension OrderSavingsAccountState {
    
    var data: OrderSavingsAccount? {
        switch status {
        case .inflight:
            return nil
            
        case let .result(result):
            return result
        }
    }
    
    var amountView: Amount {
        Amount(title: "", value: amountValue, button: .init(title: "Продолжить", isEnabled: (amountValue > 0 && !isShowingOTP && consent)))
    }
    
    func amountToString() -> String {
                
        return (formatter.string(for: amountValue) ?? "") + " " + currencyCode
    }
    
    var currencyCode: String {
        data?.currency.symbol ?? ""
    }
}
