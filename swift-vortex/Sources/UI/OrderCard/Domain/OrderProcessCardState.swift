//
//  OrderProcessCardState.swift
//
//
//  Created by Дмитрий Савушкин on 09.12.2024.
//

import Foundation
import AmountComponent

public struct OrderProcessCardState: Equatable {
    
    let status: Status
    var amountValue: Decimal
    var consent: Bool = true
    var isShowingOTP: Bool = false
    
    public init(
        status: Status,
        amountValue: Decimal = 0
    ) {
        self.status = status
        self.amountValue = amountValue
    }
}

public extension OrderProcessCardState {
    
    enum Status: Equatable {
        
        case inflight
        case result(OrderProcessCard)
    }
}

extension OrderProcessCardState {
    
    var data: OrderProcessCard? {
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
