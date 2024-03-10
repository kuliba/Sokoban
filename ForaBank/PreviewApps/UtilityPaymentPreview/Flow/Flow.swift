//
//  Flow.swift
//  UtilityPaymentPreview
//
//  Created by Igor Malyarov on 03.03.2024.
//

struct Flow {
    
    var loadLastPayments: LoadLastPayments
    var loadPrePayment: LoadPrePayment
}

extension Flow {

    enum LoadLastPayments: String, CaseIterable {
        
        case success, failure
    }

    enum LoadPrePayment: String, CaseIterable {
        
        case success, failure
    }
}
