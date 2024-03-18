//
//  LastPayment.swift
//  UtilityPaymentPreview
//
//  Created by Igor Malyarov on 10.03.2024.
//

import Foundation

struct LastPayment: Equatable, Identifiable {
    
    let id: String
    
    init(id: String = UUID().uuidString) {
    
        self.id = id
    }
}
