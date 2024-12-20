//
//  PaymentCompletion.swift
//  
//
//  Created by Igor Malyarov on 30.07.2024.
//

import SharedConfigs
import SwiftUI

public struct PaymentCompletion: Equatable {
    
    public let formattedAmount: String
    public let merchantIcon: String?
    public let status: Status
    
    public init(
        formattedAmount: String, 
        merchantIcon: String?,
        status: Status
    ) {
        self.formattedAmount = formattedAmount
        self.merchantIcon = merchantIcon
        self.status = status
    }
    
    public enum Status: Equatable {
        
        case completed, inflight, rejected
        case fraud(Fraud)
        
        public enum Fraud: Equatable {
            
            case cancelled, expired
        }
    }
}
