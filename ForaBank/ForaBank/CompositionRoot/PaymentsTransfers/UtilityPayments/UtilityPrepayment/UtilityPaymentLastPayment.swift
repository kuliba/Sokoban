//
//  UtilityPaymentLastPayment.swift
//  ForaBank
//
//  Created by Igor Malyarov on 11.05.2024.
//

import Foundation

struct UtilityPaymentLastPayment: Equatable {
    
    let amount: Decimal
    let name: String
    let md5Hash: String?
    let puref: String
}

extension UtilityPaymentLastPayment: Identifiable {
    
    var id: String { name }
}
