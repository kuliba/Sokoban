//
//  UtilityService.swift
//  UtilityPaymentPreview
//
//  Created by Igor Malyarov on 03.03.2024.
//

import Foundation

struct UtilityService: Equatable, Identifiable {
    
    let id: String
    
    init(id: String = UUID().uuidString) {
     
        self.id = id
    }
}
