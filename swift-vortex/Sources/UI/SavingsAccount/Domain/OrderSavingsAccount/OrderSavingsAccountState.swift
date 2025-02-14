//
//  OrderSavingsAccountState.swift
//  
//
//  Created by Andryusina Nataly on 25.11.2024.
//

import SwiftUI
import AmountComponent

public struct OrderSavingsAccountState: Equatable {
    
    public let status: Status
    public var amountValue: Decimal
    public var consent: Bool = true
    public var isShowingOTP: Bool = false
    

    public init(
        status: Status,
        amountValue: Decimal = 0
    ) {
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
        
    var currencyCode: String {
        data?.currency.symbol ?? ""
    }
}
