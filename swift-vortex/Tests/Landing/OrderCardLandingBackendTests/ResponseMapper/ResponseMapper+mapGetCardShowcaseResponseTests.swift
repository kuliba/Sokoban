//
//  ResponseMapper+mapGetCardShowcaseResponseTests.swift
//
//
//  Created by Дмитрий Савушкин on 10.03.2025.
//

import OrderCardLandingBackend
import RemoteServices
import XCTest

final class ResponseMapper_mapGetCardShowcaseResponseTests: XCTestCase {
    
    func test_map_shouldDeliverInvalidFailure_onEmptyData() {
        
        let emptyData: Data = .empty
        
        XCTAssertNoDiff(
            map(emptyData),
            .failure(.invalid(statusCode: 200, data: emptyData))
        )
    }
    
    func test_map_shouldDeliverInvalidFailure_onInvalidData() {
        
        let invalidData: Data = .invalidData
        
        XCTAssertNoDiff(
            map(invalidData),
            .failure(.invalid(statusCode: 200, data: invalidData))
        )
    }
    
    func test_map_shouldDeliverInvalidFailure_onEmptyJSON() {
        
        let emptyJSON: Data = .emptyJSON
        
        XCTAssertNoDiff(
            map(emptyJSON),
            .failure(.invalid(statusCode: 200, data: emptyJSON))
        )
    }
    
    func test_map_shouldDeliverInvalidFailure_onEmptyDataResponse() {
        
        let emptyDataResponse: Data = .emptyDataResponse
        
        XCTAssertNoDiff(
            map(emptyDataResponse),
            .failure(.invalid(statusCode: 200, data: emptyDataResponse))
        )
    }
    
    func test_map_shouldDeliverInvalidFailure_onNullServerResponse() {
        
        let nullServerResponse: Data = .nullServerResponse
        
        XCTAssertNoDiff(
            map(.nullServerResponse),
            .failure(.invalid(statusCode: 200, data: nullServerResponse))
        )
    }
    
    func test_map_shouldDeliverServerError_onServerError() {
        
        XCTAssertNoDiff(
            map(.serverError),
            .failure(.server(
                statusCode: 102,
                errorMessage: "Возникла техническая ошибка"
            ))
        )
    }
    
    func test_map_shouldDeliverInvalidFailure_onNonOkHTTPResponse() {
        
        for statusCode in [199, 201, 399, 400, 401, 404] {
            
            let nonOkResponse = anyHTTPURLResponse(statusCode: statusCode)
            
            XCTAssertNoDiff(
                map(.validData, nonOkResponse),
                .failure(.invalid(statusCode: statusCode, data: .validData))
            )
        }
    }
    
    func test_map_shouldDeliverResponse_onValidData() throws {
        
        XCTAssertNoDiff(map(.validData), .success(.init(products: [
            .product1,
            .product2,
            .product3
        ])))
    }
    
    // MARK: - Helpers
    
    private typealias MappingResult = ResponseMapper.MappingResult<CardShowCaseResponse>
    
    private func map(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse = anyHTTPURLResponse()
    ) -> MappingResult {
        
        ResponseMapper.mapGetCardShowcaseResponse(data, httpURLResponse)
    }
}

private extension CardShowCaseResponse.Product {
    
    static let product1: Self = .init(
        theme: "GRAY",
        name: [
            .init(text: "Карта МИР", isBold: true),
            .init(text:  "«Все включено»", isBold: true)
        ],
        features: .init(list: [
            .init(bullet: true, text: "0 ₽. Условия обслуживания"),
            .init(bullet: false, text: "Кешбэк до 10 000 ₽ в месяц")
        ]),
        image: "image",
        terms: "link",
        cardShowcaseAction: .init(
            type: "CARD_LANDING",
            target: "DEFAULT_CARD_LANDING",
            fallbackUrl: "https://fallbackurl.ru"
        )
    )
    
    static let product2: Self = .init(
        theme: "BLACK",
        name: [
            .init(text: "Пакет", isBold: false),
            .init(text: "Премиальный", isBold: true)
        ],
        features: .init(list: [
            .init(bullet: true, text: "Валюта счета: ₽/$/€"),
            .init(bullet: false, text: "Кешбэк:")
        ]),
        image: "image",
        terms: "link",
        cardShowcaseAction: .init(type: "LINK", target: "http://forabank.ru")
    )
    
    static let product3: Self = .init(
        theme: "GRAY",
        name: [
            .init(text: "«МИР", isBold: true),
            .init(text: "Пенсионная»", isBold: true)
        ],
        features: .init(
            header: "Тестовый заголовок",
            list: [
                .init(bullet: true, text: "Обслуживание 5 лет — 0 ₽"),
                .init(bullet: true, text: "Доход на остаток до 9%")
            ]
        ),
        image: "image",
        terms: "link",
        cardShowcaseAction: .init(
            type: "CARD_ORDER",
            target: "DEFAULT_CARD_ORDER_FORM",
            fallbackUrl: "forabank.ru"
        )
    )
}

private extension Data {
    
    static let empty: Data = .init()
    static let invalidData: Data = String.invalidData.json
    static let emptyJSON: Data = String.emptyJSON.json
    static let emptyDataResponse: Data = String.emptyDataResponse.json
    static let nullServerResponse: Data = String.nullServerResponse.json
    static let serverError: Data = String.serverError.json
    static let validData: Data = String.validData.json
}

private extension String {
    
    var json: Data { .init(self.utf8) }
    
    static let invalidData = """
{
    "statusCode": 102,
    "errorMessage": null,
    "data": { "a": "junk" }
}
"""
    
    static let emptyJSON = "{}"
    
    static let emptyDataResponse = """
{
    "statusCode": 102,
    "errorMessage": null,
    "data": {}
}
"""
    
    static let nullServerResponse = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": null
}
"""
    
    static let serverError = """
{
    "statusCode": 102,
    "errorMessage": "Возникла техническая ошибка",
    "data": null
}
"""
    
    static let validData = """

{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "serial": "serial",
        "products": [
            {
                "theme": "GRAY",
                "name": [
                    {
                        "text": "Карта МИР",
                        "isBold": true
                    },
                    {
                        "text": "«Все включено»",
                        "isBold": true
                    }
                ],
                "features": {
                    "list": [
                        {
                            "bullet": true,
                            "text": "0 ₽. Условия обслуживания"
                        },
                        {
                            "bullet": false,
                            "text": "Кешбэк до 10 000 ₽ в месяц"
                        }
                    ]
                },
                "image": "image",
                "terms": "link",
                "cardShowcaseAction": {
                    "type": "CARD_LANDING",
                    "target": "DEFAULT_CARD_LANDING",
                    "fallbackUrl": "https://fallbackurl.ru"
                }
            },
            {
                "theme": "BLACK",
                "name": [
                    {
                        "text": "Пакет",
                        "isBold": false
                    },
                    {
                        "text": "Премиальный",
                        "isBold": true
                    }
                ],
                "features": {
                    "list": [
                        {
                            "bullet": true,
                            "text": "Валюта счета: ₽/$/€"
                        },
                        {
                            "bullet": false,
                            "text": "Кешбэк:"
                        }
                    ]
                },
                "image": "image",
                "terms": "link",
                "cardShowcaseAction": {
                    "type": "LINK",
                    "target": "http://forabank.ru"
                }
            },
            {
                "theme": "GRAY",
                "name": [
                    {
                        "text": "«МИР",
                        "isBold": true
                    },
                    {
                        "text": "Пенсионная»",
                        "isBold": true
                    }
                ],
                "features": {
                    "header": "Тестовый заголовок",
                    "list": [
                        {
                            "bullet": true,
                            "text": "Обслуживание 5 лет — 0 ₽"
                        },
                        {
                            "bullet": true,
                            "text": "Доход на остаток до 9%"
                        }
                    ]
                },
                "image": "image",
                "terms": "link",
                "cardShowcaseAction": {
                    "type": "CARD_ORDER",
                    "target": "DEFAULT_CARD_ORDER_FORM",
                    "fallbackUrl": "forabank.ru"
                }
            }
        ]
    }
}

"""
}
