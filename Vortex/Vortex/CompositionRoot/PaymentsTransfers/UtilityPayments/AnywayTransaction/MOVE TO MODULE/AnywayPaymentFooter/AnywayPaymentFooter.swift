//
//  AnywayPaymentFooter.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.05.2024.
//

import Foundation

struct AnywayPaymentFooter: Equatable {
    
    let buttonTitle: String
    let core: Core?
    let isEnabled: Bool
}

extension AnywayPaymentFooter {
    
    struct Core: Equatable {
        
        let value: Decimal
        let currency: String
    }
}
