//
//  Button+preview.swift
//  
//
//  Created by Igor Malyarov on 23.12.2023.
//

public extension Button {
    
    static let preview: Self = .init(
        id: .buttonPay,
        value: "Оплатить",
        color: .red,
        action: .pay,
        placement: .bottom
    )
}
