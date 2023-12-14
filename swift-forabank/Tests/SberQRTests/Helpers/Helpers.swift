//
//  Helpers.swift
//
//
//  Created by Igor Malyarov on 06.12.2023.
//

import Foundation
import SberQR

extension GetSberQRDataResponse.Parameter.Amount {
    
    static func paymentAmount(
        value: Decimal
    ) -> Self {
        
        .init(
            id: .paymentAmount,
            value: value,
            title: "Сумма перевода",
            validationRules: [],
            button: .init(
                title: "Оплатить",
                action: .paySberQR,
                color: .red
            )
        )
    }
}

extension GetSberQRDataResponse.Parameter.Button {
    
    static let buttonPay: Self = .init(
        id: .buttonPay,
        value: "Оплатить",
        color: .red,
        action: .pay,
        placement: .bottom
    )
}

extension GetSberQRDataResponse.Parameter.DataString {
    
    static let rub: Self = .init(id: .currency, value: "RUB")
}

extension GetSberQRDataResponse.Parameter.Header {
    
    static let payQR: Self = .init(
        id: .title,
        value: "Оплата по QR-коду"
    )
}

extension GetSberQRDataResponse.Parameter.Info {
    
    static let amount: Self = .init(
        id: .amount,
        value: "220 ₽",
        title: "Сумма",
        icon: .init(
            type: .local,
            value: "ic24IconMessage"
        )
    )
    
    static func brandName(
        value: String
    ) -> Self {
        
        .init(
            id: .brandName,
            value: value,
            title: "Получатель",
            icon: .init(
                type: .remote,
                value: "b6e5b5b8673544184896724799e50384"
            )
        )
    }
    
    static let recipientBank: Self = .init(
        id: .recipientBank,
        value: "Сбербанк",
        title: "Банк получателя",
        icon: .init(
            type: .remote,
            value: "c37971b7264d55c3c467d2127ed600aa"
        )
    )
}

extension GetSberQRDataResponse.Parameter.ProductSelect {
    
    static let debitAccount: Self = .init(
        id: "debit_account",
        value: nil,
        title: "Счет списания",
        filter: .init(
            productTypes: [.card, .account],
            currencies: [.rub],
            additional: false
        )
    )
}

extension ProductSelect.Product {
    
    static let test: Self = .init(
        id: 12345678,
        type: .card,
        header: "Счет списания",
        title: "Title",
        footer: "5678",
        amountFormatted: "12.67 $",
        look: .test(color: "red")
    )
    
    static let test2: Self = .init(
        id: 23456789,
        type: .card,
        header: "Счет списания",
        title: "Title",
        footer: "6789",
        amountFormatted: "4.21 $",
        look: .test(color: "blue")
    )
    
    static let missing: Self = .init(
        id: 1111111,
        type: .card,
        header: "Счет списания",
        title: "Title",
        footer: "1111",
        amountFormatted: "12.67 $",
        look: .test(color: "red")
    )
}

extension ProductSelect.Product.Look {
    
    static func test(color: String = "red") -> Self {
        
        .init(
            background: .svg(""),
            color: color,
            icon: .svg(""),
            logo: .svg("")
        )
    }
}

func makeEditableAmount(
    brandName: String = UUID().uuidString,
    productSelect: ProductSelect = .compact(.test),
    amount: Decimal = 123.45
) -> SberQRConfirmPaymentState.EditableAmount {
    
    .init(
        header: .payQR,
        productSelect: productSelect,
        brandName: .brandName(value: brandName),
        recipientBank: .recipientBank,
        currency: .rub,
        bottom: .paymentAmount(value: amount)
    )
}

func makeFixedAmount(
    brandName: String = UUID().uuidString,
    productSelect: ProductSelect = .compact(.test)
) -> SberQRConfirmPaymentState.FixedAmount {
    
    .init(
        header: .payQR,
        productSelect: productSelect,
        brandName: .brandName(value: brandName),
        amount: .amount,
        recipientBank: .recipientBank,
        bottom: .buttonPay
    )
}
