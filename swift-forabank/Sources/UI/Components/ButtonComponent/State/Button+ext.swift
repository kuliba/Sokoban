//
//  Button+ext.swift
//
//
//  Created by Igor Malyarov on 22.06.2024.
//

public extension Button {
    
    static func bottomPay(title: String) -> Self {
        
        return .init(
            id: .buttonPay,
            value: title,
            color: .red,
            action: .pay,
            placement: .bottom
        )
    }
}
