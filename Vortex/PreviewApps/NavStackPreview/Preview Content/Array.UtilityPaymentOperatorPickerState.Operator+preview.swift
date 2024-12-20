//
//  ArrayUtilityPaymentOperatorPickerState.Operator+preview.swift
//  NavStackPreview
//
//  Created by Igor Malyarov on 23.04.2024.
//

import Foundation

extension Array where Element == UtilityPaymentOperatorPickerState<String>.Operator {
    
    static var preview: Self {
        
        (0..<10).map { _ in
            
            return .init(id: UUID().uuidString, icon: UUID().uuidString)
        }
    }
}
