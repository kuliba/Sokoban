//
//  FlowSettings.swift
//  UtilityPaymentPreview
//
//  Created by Igor Malyarov on 03.03.2024.
//

struct FlowSettings: Equatable {
    
    var loadLastPayments: LoadLastPayments
    var loadOperators: LoadOperators
    var loadPrepayment: LoadPrepayment
}

extension FlowSettings {
    
    enum LoadLastPayments: String, CaseIterable {
        
        case success, failure
    }
    
    enum LoadOperators: String, CaseIterable {
        
        case success, failure
    }
    
    enum LoadPrepayment: String, CaseIterable {
        
        case success, failure
    }
}
