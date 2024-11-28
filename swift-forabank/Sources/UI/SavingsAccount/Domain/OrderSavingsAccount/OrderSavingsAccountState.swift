//
//  OrderSavingsAccountState.swift
//  
//
//  Created by Andryusina Nataly on 25.11.2024.
//

import SwiftUI
import AmountComponent

public struct OrderSavingsAccountState: Equatable {
    
    let status: Status
    var amountValue: Decimal
    var isShowingOTP: Bool = false
    var consent: Bool = true

    public init(status: Status, amountValue: Decimal = 0) {
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
        
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        formatter.currencyCode = currencyCode
        formatter.numberStyle = .currency
        
        return formatter.string(for: amountValue) ?? ""
    }
    
    var currencyCode: String {
        data?.currency.symbol ?? ""
    }
}
