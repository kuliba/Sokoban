//
//  UtilityServicePickerState.Operator+preview.swift
//  NavStackPreview
//
//  Created by Igor Malyarov on 23.04.2024.
//

import Foundation

extension UtilityServicePickerState.Operator where Icon == String {
    
    static var preview: Self {
 
        .init(
            name: UUID().uuidString,
            inn: UUID().uuidString,
            icon: UUID().uuidString
        )
    }
}
