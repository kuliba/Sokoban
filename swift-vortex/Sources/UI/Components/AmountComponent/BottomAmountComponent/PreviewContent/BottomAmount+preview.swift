//
//  BottomAmount+preview.swift
//
//
//  Created by Igor Malyarov on 20.06.2024.
//

import Foundation

extension BottomAmount {
    
    static func preview(
        _ value: Decimal = 12.34,
        _ button: BottomAmount.AmountButton = .enabled,
        _ status: BottomAmount.Status? = nil
    ) -> Self {
        
        return .init(value: value, button: button, status: status)
    }
}

extension BottomAmount.AmountButton {
    
    static let enabled: Self = .init(title: "Pay", isEnabled: true)
    static let disabled: Self = .init(title: "Continue", isEnabled: false)
}
