//
//  ResponseMapper+mapGetSberQRDataResponseTests.swift
//
//
//  Created by Igor Malyarov on 03.12.2023.
//

import XCTest

final class ResponseMapper_mapGetSberQRDataResponseTests: XCTestCase {
    
    func test_mapGetSberQRDataResponse_shouldDeliverInvalidErrorOnInvalidData() throws {
        
        let invalidData = anyData()
        
        let result = try map(invalidData)
        
        assert(result, equals: .failure(.invalid(statusCode: 200, data: invalidData)))
    }
    
    func test_mapGetSberQRDataResponse_shouldDeliverServerErrorOnNilData() throws {
        
        let result = try map(jsonWithError)
        
        assert(result, equals: .failure(.server(
            statusCode: 102,
            errorMessage: "Возникла техническая ошибка"
        )))
    }
    
    func test_mapGetSberQRDataResponse_shouldDeliverServerErrorOnServerErrorWithNonOkHTTPURLResponseStatusCode() throws {
        
        let nonOkResponse = anyHTTPURLResponse(statusCode: 400)
        let result = try map(jsonWithError, nonOkResponse)
        
        assert(result, equals: .failure(.server(
            statusCode: 102,
            errorMessage: "Возникла техническая ошибка"
        )))
    }
    
    func test_mapGetSberQRDataResponse_shouldDeliverInvalidOnNonOKHTTPURLResponseStatusCode() throws {
        
        let statusCode = 400
        let data = anyData()
        let nonOkResponse = anyHTTPURLResponse(statusCode: statusCode)
        let result = try map(data, nonOkResponse)
        
        assert(result, equals: .failure(.invalid(statusCode: statusCode, data: data)))
    }
    
    func test_mapGetSberQRDataResponse_shouldDeliverResponseWithAmount() throws {
        
        let result = try map(jsonWithAmount)
        
        assert(result, equals: .success(.init(
            qrcID: "04a7ae2bee8f4f13ab151c1e6066d304",
            parameters: [
                header(),
                debitAccount(),
                brandName(value: "сббол енот_QR"),
                amount(),
                recipientBank(),
                buttonPay(),
            ],
            required: [
                .debitAccount
            ]
        )))
    }
    
    func test_mapGetSberQRDataResponse_shouldDeliverResponseWithoutAmount() throws {
        
        let result = try map(jsonWithoutAmount)
        
        assert(result, equals: .success(.init(
            qrcID: "a6a05778867f439b822e7632036a9b45",
            parameters: [
                header(),
                debitAccount(),
                brandName(value: "Тест Макусов. Кутуза_QR"),
                recipientBank(),
                paymentAmount(),
                currency(),
            ],
            required: [
                .debitAccount,
                .paymentAmount,
                .currency
            ]
        )))
    }
    
    // MARK: - Helpers
    
    private func map(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse = anyHTTPURLResponse()
    ) throws -> ResponseMapper.GetSberQRDataResult {
        
        try ResponseMapper.mapGetSberQRDataResponse(
            data,
            httpURLResponse
        )
    }
    
    private func map(
        _ string: String,
        _ httpURLResponse: HTTPURLResponse = anyHTTPURLResponse()
    ) throws -> ResponseMapper.GetSberQRDataResult {
        
        try ResponseMapper.mapGetSberQRDataResponse(
            .init(string.utf8),
            httpURLResponse
        )
    }
    
    private func assert(
        _ receivedResult: ResponseMapper.GetSberQRDataResult,
        equals expectedResult: ResponseMapper.GetSberQRDataResult,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        switch (receivedResult, expectedResult) {
        case let (
            .failure(received),
            .failure(expected)
        ):
            XCTAssertNoDiff(received, expected, file: file, line: line)
            
        case let (
            .success(received),
            .success(expected)
        ):
            XCTAssertNoDiff(received, expected, file: file, line: line)
            
        default:
            XCTFail("\nExpected \(expectedResult), but got \(receivedResult) instead.", file: file, line: line)
        }
    }
    
    private func header() -> GetSberQRDataResponse.Parameter {
        
        .header(.init(
            id: .title,
            value: "Оплата по QR-коду"
        ))
    }
    
    private func debitAccount() -> GetSberQRDataResponse.Parameter {
        
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
    
    private func brandName(
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
    
    private func amount() -> GetSberQRDataResponse.Parameter {
        
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
    
    private func recipientBank() -> GetSberQRDataResponse.Parameter {
        
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
    
    private func buttonPay() -> GetSberQRDataResponse.Parameter {
        
        .button(.init(
            id: .buttonPay,
            value: "Оплатить",
            color: .red,
            action: .pay,
            placement: .bottom
        ))
    }
    
    private func paymentAmount() -> GetSberQRDataResponse.Parameter {
        
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
    
    private func currency() -> GetSberQRDataResponse.Parameter {
        
        .dataString(.init(id: "currency", value: "RUB"))
    }
}

private let jsonWithError = """
{
    "statusCode": 102,
    "errorMessage": "Возникла техническая ошибка",
    "data": null
}
"""

private let jsonWithAmount = """
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

private let jsonWithoutAmount = """
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
