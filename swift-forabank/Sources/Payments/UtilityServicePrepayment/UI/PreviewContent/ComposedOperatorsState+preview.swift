//
//  PrepaymentPickerState+preview.swift
//
//
//  Created by Igor Malyarov on 11.05.2024.
//

import UtilityServicePrepaymentDomain

extension PrepaymentPickerState
where LastPayment == PreviewLastPayment,
      Operator == PreviewOperator {
    
    static var preview: Self {
        
        return .init(
            lastPayments: .preview,
            operators: .preview,
            searchText: "abc"
        )
    }
}

struct PreviewLastPayment: Identifiable {
    
    let id: String
}

extension Array where Element == PreviewLastPayment {
    
    static let preview: Self = .init()
}

struct PreviewOperator: Identifiable {
    
    let id: String
}

extension Array where Element == PreviewOperator {
    
    static let preview: Self = .init()
}
