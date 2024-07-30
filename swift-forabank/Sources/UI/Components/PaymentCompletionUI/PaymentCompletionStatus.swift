//
//  PaymentCompletionStatus.swift
//
//
//  Created by Igor Malyarov on 30.07.2024.
//

import SwiftUI

struct PaymentCompletionStatus {
    
    let status: Status
    let formattedAmount: String
    let merchantLogo: Image?
    
    struct Status: Equatable {
        
        let logo: Image
        let title: String
        let subtitle: String?
    }
}
