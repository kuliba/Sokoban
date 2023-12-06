//
//  GetSberQRDataResponseTests.swift
//
//
//  Created by Igor Malyarov on 06.12.2023.
//

import XCTest

class GetSberQRDataResponseTests: XCTestCase {
    
    func fixedAmountParameters() -> [GetSberQRDataResponse.Parameter] {
        
        return [
            header(),
            debitAccount(),
            brandName(value: "сббол енот_QR"),
            amount(),
            recipientBank(),
            buttonPay(),
        ]
    }
    
    func editableAmountParameters() -> [GetSberQRDataResponse.Parameter] {
        
        return [
            header(),
            debitAccount(),
            brandName(value: "Тест Макусов. Кутуза_QR"),
            recipientBank(),
            paymentAmount(),
            currency(),
        ]
    }
    
    func header() -> GetSberQRDataResponse.Parameter {
        
        .header(.init(
            id: .title,
            value: "Оплата по QR-коду"
        ))
    }
    
    func debitAccount() -> GetSberQRDataResponse.Parameter {
        
        .productSelect(.init(
            id: .debitAccount,
            value: nil,
            title: "Счет списания",
            filter: .init(
                productTypes: [.card, .account],
                currencies: [.rub],
                additional: false
            )
        ))
    }
    
    func brandName(
        value: String
    ) -> GetSberQRDataResponse.Parameter {
        
        .info(.init(
            id: .brandName,
            value: value,
            title: "Получатель",
            icon: .init(
                type: .remote,
                value: "b6e5b5b8673544184896724799e50384"
            )
        ))
    }
    
    func amount() -> GetSberQRDataResponse.Parameter {
        
        .info(.init(
            id: .amount,
            value: "220 ₽",
            title: "Сумма",
            icon: .init(
                type: .local,
                value: "ic24IconMessage"
            )
        ))
    }
    
    func recipientBank() -> GetSberQRDataResponse.Parameter {
        
        .info(.init(
            id: .recipientBank,
            value: "Сбербанк",
            title: "Банк получателя",
            icon: .init(
                type: .remote,
                value: "c37971b7264d55c3c467d2127ed600aa"
            )
        ))
    }
    
    func buttonPay() -> GetSberQRDataResponse.Parameter {
        
        .button(.init(
            id: .buttonPay,
            value: "Оплатить",
            color: .red,
            action: .pay,
            placement: .bottom
        ))
    }
    
    func paymentAmount() -> GetSberQRDataResponse.Parameter {
        
        .amount(.init(
            id: .paymentAmount,
            value: nil,
            title: "Сумма перевода",
            validationRules: [],
            button: .init(
                title: "Оплатить",
                action: .paySberQR,
                color: .red
            )
        ))
    }
    
    func currency() -> GetSberQRDataResponse.Parameter {
        
        .dataString(.init(id: "currency", value: "RUB"))
    }

    let jsonWithError = """
    {
        "statusCode": 102,
        "errorMessage": "Возникла техническая ошибка",
        "data": null
    }
    """

    let jsonWithAmount = """
    {
        "statusCode": 0,
        "errorMessage": null,
        "data": {
            "qrcId": "04a7ae2bee8f4f13ab151c1e6066d304",
            "parameters": [{
                    "id": "title",
                    "type": "HEADER",
                    "value": "Оплата по QR-коду"
                },
                {
                    "id": "debit_account",
                    "type": "PRODUCT_SELECT",
                    "value": null,
                    "title": "Счет списания",
                    "filter": {
                        "productTypes": [
                            "CARD",
                            "ACCOUNT"
                        ],
                        "currencies": [
                            "RUB"
                        ],
                        "additional": false
                    }
                },
                {
                    "id": "brandName",
                    "type": "INFO",
                    "value": "сббол енот_QR",
                    "title": "Получатель",
                    "icon": {
                        "type": "REMOTE",
                        "value": "b6e5b5b8673544184896724799e50384"
                    }
                },
                {
                    "id": "amount",
                    "type": "INFO",
                    "value": "220 ₽",
                    "title": "Сумма",
                    "icon": {
                        "type": "LOCAL",
                        "value": "ic24IconMessage"
                    }
                },
                {
                    "id": "recipientBank",
                    "type": "INFO",
                    "value": "Сбербанк",
                    "title": "Банк получателя",
                    "icon": {
                        "type": "REMOTE",
                        "value": "c37971b7264d55c3c467d2127ed600aa"
                    }
                },
                {
                    "id": "button_pay",
                    "type": "BUTTON",
                    "value": "Оплатить",
                    "color": "red",
                    "action": "PAY",
                    "placement": "BOTTOM"
                }
            ],
            "required": [
                "debit_account"
            ]
        }
    }
    """

    let jsonWithoutAmount = """
    {
        "statusCode": 0,
        "errorMessage": null,
        "data": {
            "qrcId": "a6a05778867f439b822e7632036a9b45",
            "parameters": [{
                    "id": "title",
                    "type": "HEADER",
                    "value": "Оплата по QR-коду"
                },
                {
                    "id": "debit_account",
                    "type": "PRODUCT_SELECT",
                    "value": null,
                    "title": "Счет списания",
                    "filter": {
                        "productTypes": [
                            "CARD",
                            "ACCOUNT"
                        ],
                        "currencies": [
                            "RUB"
                        ],
                        "additional": false
                    }
                },
                {
                    "id": "brandName",
                    "type": "INFO",
                    "value": "Тест Макусов. Кутуза_QR",
                    "title": "Получатель",
                    "icon": {
                        "type": "REMOTE",
                        "value": "b6e5b5b8673544184896724799e50384"
                    }
                },
                {
                    "id": "recipientBank",
                    "type": "INFO",
                    "value": "Сбербанк",
                    "title": "Банк получателя",
                    "icon": {
                        "type": "REMOTE",
                        "value": "c37971b7264d55c3c467d2127ed600aa"
                    }
                },
                {
                    "id": "payment_amount",
                    "type": "AMOUNT",
                    "value": null,
                    "title": "Сумма перевода",
                    "validationRules": [],
                    "button": {
                        "title": "Оплатить",
                        "action": "PAY_SBER_QR",
                        "color": "red"
                    }
                },
                {
                    "id": "currency",
                    "type": "DATA_STRING",
                    "value": "RUB"
                }
            ],
            "required": [
                "debit_account",
                "payment_amount",
                "currency"
            ]
        }
    }
    """
}
