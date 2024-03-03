//
//  Flow.swift
//  UtilityPaymentPreview
//
//  Created by Igor Malyarov on 03.03.2024.
//

struct Flow {
    
    var loadPrePayment: LoadPrePayment
}

extension Flow {

    enum LoadPrePayment: String, CaseIterable {
        
        case success, connectivity, serverError
    }
}
