//
//  Flow.swift
//  UtilityPaymentPreview
//
//  Created by Igor Malyarov on 03.03.2024.
//

struct Flow: Equatable {
    
    var loadLastPayments: LoadLastPayments
    var loadOperators: LoadOperators
}

extension Flow {
    
    enum LoadLastPayments: String, CaseIterable {
        
        case success, failure
    }
    
    enum LoadOperators: String, CaseIterable {
        
        case success, failure
    }
}
