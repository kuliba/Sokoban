//
//  Helpers.swift
//
//
//  Created by Igor Malyarov on 13.03.2024.
//

import Foundation

struct LastPayment: Equatable {
    
    var value: String
    
    init(value: String = UUID().uuidString) {
        
        self.value = value
    }
}

struct Operator: Equatable {
    
    var value: String
    
    init(value: String = UUID().uuidString) {
        
        self.value = value
    }
}

struct UtilityService: Equatable {
    
    var value: String
    
    init(value: String = UUID().uuidString) {
        
        self.value = value
    }
}
