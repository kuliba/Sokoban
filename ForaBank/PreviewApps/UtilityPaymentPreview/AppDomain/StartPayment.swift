//
//  StartPayment.swift
//  UtilityPaymentPreview
//
//  Created by Igor Malyarov on 17.03.2024.
//

import Foundation

struct StartPayment: Equatable {
    
    let value: String
    
    init(value: String = UUID().uuidString) {
    
        self.value = value
    }
}
