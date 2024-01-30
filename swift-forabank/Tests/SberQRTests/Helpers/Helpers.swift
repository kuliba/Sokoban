//
//  Helpers.swift
//
//
//  Created by Igor Malyarov on 06.12.2023.
//

import Foundation
import PaymentComponents
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

extension Amount {
    
    static func paymentAmount(
        value: Decimal,
        isEnabled: Bool
    ) -> Self {
        
        .init(
            title: "Сумма перевода",
            value: value,
            button: .init(
                title: "Оплатить",
                isEnabled: isEnabled
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
        id: .debit_account,
        value: nil,
        title: "Счет списания",
        filter: .init(
            productTypes: [.card, .account],
            currencies: [.rub],
            additional: false
        )
    )
}

func makeEditableAmount(
    brandName: String = UUID().uuidString,
    productSelect: ProductSelect = .compact(.test),
    amount: Decimal = 123.45,
    isEnabled: Bool = false
) -> EditableAmount<GetSberQRDataResponse.Parameter.Info> {
    
    .init(
        header: .payQR,
        productSelect: productSelect,
        brandName: .brandName(value: brandName),
        recipientBank: .recipientBank,
        currency: .rub,
        amount: .paymentAmount(
            value: amount,
            isEnabled: isEnabled
        )
    )
}

func makeFixedAmount(
    brandName: String = UUID().uuidString,
    productSelect: ProductSelect = .compact(.test)
) -> FixedAmount<GetSberQRDataResponse.Parameter.Info> {
    
    .init(
        header: .payQR,
        productSelect: productSelect,
        brandName: .brandName(value: brandName),
        amount: .amount,
        recipientBank: .recipientBank,
        button: .preview
    )
}
