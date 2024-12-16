//
//  ArrayUtilityPaymentOperatorPickerState.LastPayment+preview.swift
//  NavStackPreview
//
//  Created by Igor Malyarov on 23.04.2024.
//

import Foundation

extension Array where Element == UtilityPaymentOperatorPickerState<String>.LastPayment {
    
    static var preview: Self {
        
        (0..<5).map { _ in
            
            return .init(id: UUID().uuidString, icon: UUID().uuidString)
        }
    }
}
