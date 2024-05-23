//
//  AnywayPaymentFooterEvent.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.05.2024.
//

import Foundation

enum AnywayPaymentFooterEvent: Equatable {
    
    case `continue`
    case edit(Decimal)
}
