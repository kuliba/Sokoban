//
//  UtilityServicePickerState.Operator+preview.swift
//  NavStackPreview
//
//  Created by Igor Malyarov on 23.04.2024.
//

import Foundation

extension UtilityServicePickerState.Operator {
    
    static let preview: Self = .init(
        name: UUID().uuidString,
        inn: UUID().uuidString,
        icon: UUID().uuidString
    )
}
