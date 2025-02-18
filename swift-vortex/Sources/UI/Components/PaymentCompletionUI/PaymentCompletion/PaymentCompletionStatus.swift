//
//  PaymentCompletionStatus.swift
//
//
//  Created by Igor Malyarov on 30.07.2024.
//

import SwiftUI

struct PaymentCompletionStatus {
    
    let formattedAmount: String
    let merchantIcon: String?
    let status: Status
    
    struct Status: Equatable {
        
        let logo: Image
        let title: String
        let subtitle: String?
    }
}
