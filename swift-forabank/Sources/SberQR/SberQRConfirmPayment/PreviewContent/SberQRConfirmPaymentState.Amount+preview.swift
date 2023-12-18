//
//  SberQRConfirmPaymentState.Amount+preview.swift
//  
//
//  Created by Igor Malyarov on 18.12.2023.
//

extension SberQRConfirmPaymentState.Amount {
    
    static let preview: Self = .init(
        title: "Сумма перевода",
        value: 12_345.45,
        button: .init(title: "Оплатить")
    )
}
