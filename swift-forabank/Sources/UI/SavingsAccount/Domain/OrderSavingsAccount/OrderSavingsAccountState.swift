//
//  OrderSavingsAccountState.swift
//  
//
//  Created by Andryusina Nataly on 25.11.2024.
//

import SwiftUI

public struct OrderSavingsAccountState: Equatable {
    
    let status: Status
    
    public init(status: Status) {
        self.status = status
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
}
