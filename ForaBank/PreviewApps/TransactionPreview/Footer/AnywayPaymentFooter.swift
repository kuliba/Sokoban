//
//  AnywayPaymentFooter.swift
//  AnywayPaymentPreview
//
//  Created by Igor Malyarov on 14.04.2024.
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

enum AnywayPaymentFooterEvent: Equatable {
    
    case `continue`
    case edit(Decimal)
}
