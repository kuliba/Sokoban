//
//  PaymentCompletion.swift
//  
//
//  Created by Igor Malyarov on 30.07.2024.
//

import SharedConfigs
import SwiftUI

struct PaymentCompletion: Equatable {
    
    let formattedAmount: String
    let merchantIcon: Image?
    let status: Status
    
    enum Status: Equatable {
        
        case completed, inflight, rejected
        case fraud(Fraud)
        
        enum Fraud: Equatable {
            
            case cancelled, expired
        }
    }
}
