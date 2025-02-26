//
//  ResponseMapper+mapOrderCardLandingResponseTests.swift
//  
//
//  Created by Дмитрий Савушкин on 03.12.2024.
//

import OrderCardLandingBackend
import XCTest
import RemoteServices
import UIPrimitives
import OrderCardLandingBackend

final class ResponseMapper_mapOrderCardLandingResponseTests: XCTestCase {
    
    // TODO: fixme
//    func test_map_shouldDeliverValidData() {
//        
//        XCTAssertNoDiff(
//            map(.validData),
//            .success(.stub)
//        )
//    }
    
    // TODO: fixme
//    func test_map_shouldDeliverValidDataWithEmptyConditions() {
//
//        XCTAssertNoDiff(
//            map(.validDataWithEmptyConditions),
//            .success(.stubWithEmptyConditions)
//        )
//    }
    
    // TODO: fixme
//    func test_map_shouldDeliverValidDataWithEmptySecurity() {
//
//        XCTAssertNoDiff(
//            map(.validDataWithEmptySecurity),
//            .success(.stubWithEmptySecurity)
//        )
//    }
    
    // TODO: fixme
//    func test_map_shouldDeliverValidDataWithEmptyQuestions() {
//        
//        XCTAssertNoDiff(
//            map(.validDataWithEmptyQuestions),
//            .success(.stubWithEmptyQuestion)
//        )
//    }
    
    func test_map_shouldDeliverInvalidFailureOnEmptyData() {
        
        XCTAssertNoDiff(
            map(.empty),
            .failure(.invalid(statusCode: 200, data: .empty))
        )
    }
    
    func test_map_shouldDeliverInvalidFailureOnInvalidData() {
        
        XCTAssertNoDiff(
            map(.invalidData),
            .failure(.invalid(statusCode: 200, data: .invalidData))
        )
    }
    
    func test_map_shouldDeliverInvalidFailureOnEmptyJSON() {
        
        XCTAssertNoDiff(
            map(.emptyJSON),
            .failure(.invalid(statusCode: 200, data: .emptyJSON))
        )
    }
    
    func test_map_shouldDeliverInvalidFailureOnEmptyDataResponse() {
        
        XCTAssertNoDiff(
            map(.emptyDataResponse),
            .failure(.invalid(statusCode: 200, data: .emptyDataResponse))
        )
    }
    
    func test_map_shouldDeliverInvalidFailureOnNullServerResponse() {
        
        XCTAssertNoDiff(
            map(.nullServerResponse),
            .failure(.invalid(statusCode: 200, data: .nullServerResponse))
        )
    }
    
    func test_map_shouldDeliverServerErrorOnServerError() {
        
        XCTAssertNoDiff(
            map(.serverError),
            .failure(.server(
                statusCode: 102,
                errorMessage: "Возникла техническая ошибка"
            ))
        )
    }
    
    func test_map_shouldDeliverInvalidFailureOnNonOkHTTPResponse() throws {
        
        for statusCode in [199, 201, 399, 400, 401, 404] {
            let nonOkResponse = anyHTTPURLResponse(statusCode: statusCode)
            
            XCTAssertNoDiff(
                map(.validData, nonOkResponse),
                .failure(.invalid(statusCode: statusCode, data: .validData))
            )
        }
    }
    
    func test_map_shouldDeliverInvalidFailureOnEmptyList() {
        
        let emptyDataResponse: Data = .emptyListResponse
        
        XCTAssertNoDiff(
            map(emptyDataResponse),
            .failure(.invalid(statusCode: 200, data: emptyDataResponse))
        )
    }
    
    // MARK: - Helpers
    
    private typealias MappingResult = Swift.Result<
        OrderCardLandingBackend.OrderCardLandingResponse,
        ResponseMapper.MappingError
    >
    
    private func map(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse = anyHTTPURLResponse()
    ) -> MappingResult {
        ResponseMapper.mapOrderCardLandingResponse(data, httpURLResponse)
    }
}

private extension Data {
    
    static let empty: Data = .init()
    static let invalidData: Data = String.invalidData.json
    static let emptyJSON: Data = String.emptyJSON.json
    static let emptyDataResponse: Data = String.emptyDataResponse.json
    static let emptyListResponse: Data = String.emptyList.json
    static let nullServerResponse: Data = String.nullServerResponse.json
    static let serverError: Data = String.serverError.json
    static let validData: Data = String.validJson.json
    static let validDataWithEmptyConditions: Data = String.validJsonWithEmptyConditions.json
    static let validDataWithEmptySecurity: Data = String.validJsonWithEmptySecurity.json
    static let validDataWithEmptyQuestions: Data = String.validJsonWithEmptyFrequentlyAskedQuestions.json
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
    
    static let emptyList = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": []
}
"""
    
    static let validJson = """
{
"statusCode": 200,
"errorMessage": null,
"data": {
    "id": "CARD_NAME_PRODUCT",
    "theme": "DEFAULT",
    "product": {
        "title": "Карта МИР «Все включено»",
        "image": "dict/getProductCatalogImage?image=/products/banners/car_collateral_loan.png",
        "features": [
            "кешбэк до 10 000 ₽ в месяц",
            "5% выгода при покупке топлива",
            "5% на категории сезона",
            "от 0,5% до 1% кешбэк на остальные покупки**"
        ],
        "discounts": {
            "title": "Скидки на переводы",
            "list": [{
                "md5hash": "b6fa019f307d6a72951ab7268708aa15",
                "title": "СБП"
            }, {
                "md5hash": "b6fa019f307d6a72951ab7268708aa15",
                "title": "За рубеж"
            }, {
                "md5hash": "b6fa019f307d6a72951ab7268708aa15",
                "title": "ЖКХ"
            }, {
                "md5hash": "b6fa019f307d6a72951ab7268708aa15",
                "title": "Налоги"
            }]
        }
    },
    "conditions": {
        "title": "Выгодные условия",
        "list": [{
            "md5hash": "b6fa019f307d6a72951ab7268708aa15",
            "title": "0 ₽",
            "subTitle": "Условия обслуживания"
        }, {
            "md5hash": "b6fa019f307d6a72951ab7268708aa15",
            "title": "До 35%",
            "subTitle": "Кешбэк и скидки"
        }, {
            "md5hash": "b6fa019f307d6a72951ab7268708aa15",
            "title": "Кешбэк 5%",
            "subTitle": "На востребованные категории"
        }, {
            "md5hash": "b6fa019f307d6a72951ab7268708aa15",
            "title": "Кешбэк 5%",
            "subTitle": "На топливо и 3% кешбэк на кофе"
        }, {
            "md5hash": "b6fa019f307d6a72951ab7268708aa15",
            "title": "8% годовых",
            "subTitle": "При сумме остатка от 500 001 ₽"
        }]
    },
    "security": {
        "title": "Безопасность",
        "list": [{
            "md5hash": "b6fa019f307d6a72951ab7268708aa15",
            "title": "Ваши средства застрахованы в АСВ",
            "subTitle": "Банк входит в систему страхования вкладов Агентства по страхованию вкладов"
        }, {
            "md5hash": "b6fa019f307d6a72951ab7268708aa15",
            "title": "Безопасные платежи в Интернете (3-D Secure)",
            "subTitle": "3-D Secure — технология, предназначенная для повышения безопасности расчетов"
        }, {
            "md5hash": "b6fa019f307d6a72951ab7268708aa15",
            "title": "Блокировка подозрительных операций",
            "subTitle": "На востребованные категории"
        }]
    },
    "frequentlyAskedQuestions": {
        "title": "Часто задаваемые вопросы",
        "list": [{
            "title": "Как повторно подключить подписку?",
            "description": "тест"
        }, {
            "title": "Как начисляются проценты?",
            "description": "тесттесттесттесттесттесттесттест"
        }, {
            "title": "Какие условия бесплатного обслуживания?",
            "description": ""
        }]
    }
}
}
"""

static let validJsonWithEmptySecurity = """
{
"statusCode": 200,
"errorMessage": null,
"data": {
"id": "CARD_NAME_PRODUCT",
"theme": "DEFAULT",
"product": {
    "title": "Карта МИР «Все включено»",
    "image": "dict/getProductCatalogImage?image=/products/banners/car_collateral_loan.png",
    "features": [
        "кешбэк до 10 000 ₽ в месяц",
        "5% выгода при покупке топлива",
        "5% на категории сезона",
        "от 0,5% до 1% кешбэк на остальные покупки**"
    ],
    "discounts": {
        "title": "Скидки на переводы",
        "list": [{
            "md5hash": "b6fa019f307d6a72951ab7268708aa15",
            "title": "СБП"
        }, {
            "md5hash": "b6fa019f307d6a72951ab7268708aa15",
            "title": "За рубеж"
        }, {
            "md5hash": "b6fa019f307d6a72951ab7268708aa15",
            "title": "ЖКХ"
        }, {
            "md5hash": "b6fa019f307d6a72951ab7268708aa15",
            "title": "Налоги"
        }]
    }
},
"conditions": {
    "title": "Выгодные условия",
    "list": [{
        "md5hash": "b6fa019f307d6a72951ab7268708aa15",
        "title": "0 ₽",
        "subTitle": "Условия обслуживания"
    }, {
        "md5hash": "b6fa019f307d6a72951ab7268708aa15",
        "title": "До 35%",
        "subTitle": "Кешбэк и скидки"
    }, {
        "md5hash": "b6fa019f307d6a72951ab7268708aa15",
        "title": "Кешбэк 5%",
        "subTitle": "На востребованные категории"
    }, {
        "md5hash": "b6fa019f307d6a72951ab7268708aa15",
        "title": "Кешбэк 5%",
        "subTitle": "На топливо и 3% кешбэк на кофе"
    }, {
        "md5hash": "b6fa019f307d6a72951ab7268708aa15",
        "title": "8% годовых",
        "subTitle": "При сумме остатка от 500 001 ₽"
    }]
},
"security": {
    "title": "Безопасность",
    "list": []
},
"frequentlyAskedQuestions": {
    "title": "Часто задаваемые вопросы",
    "list": [{
        "title": "Как повторно подключить подписку?",
        "description": "тест"
    }, {
        "title": "Как начисляются проценты?",
        "description": "тесттесттесттесттесттесттесттест"
    }, {
        "title": "Какие условия бесплатного обслуживания?",
        "description": ""
    }]
}
}
}
"""

static let validJsonWithEmptyConditions = """
{
"statusCode": 200,
"errorMessage": null,
"data": {
"id": "CARD_NAME_PRODUCT",
"theme": "DEFAULT",
"product": {
    "title": "Карта МИР «Все включено»",
    "image": "dict/getProductCatalogImage?image=/products/banners/car_collateral_loan.png",
    "features": [
        "кешбэк до 10 000 ₽ в месяц",
        "5% выгода при покупке топлива",
        "5% на категории сезона",
        "от 0,5% до 1% кешбэк на остальные покупки**"
    ],
    "discounts": {
        "title": "Скидки на переводы",
        "list": [{
            "md5hash": "b6fa019f307d6a72951ab7268708aa15",
            "title": "СБП"
        }, {
            "md5hash": "b6fa019f307d6a72951ab7268708aa15",
            "title": "За рубеж"
        }, {
            "md5hash": "b6fa019f307d6a72951ab7268708aa15",
            "title": "ЖКХ"
        }, {
            "md5hash": "b6fa019f307d6a72951ab7268708aa15",
            "title": "Налоги"
        }]
    }
},
"conditions": {
    "title": "Выгодные условия",
    "list": []
},
"security": {
    "title": "Безопасность",
    "list": [{
        "md5hash": "b6fa019f307d6a72951ab7268708aa15",
        "title": "Ваши средства застрахованы в АСВ",
        "subTitle": "Банк входит в систему страхования вкладов Агентства по страхованию вкладов"
    }, {
        "md5hash": "b6fa019f307d6a72951ab7268708aa15",
        "title": "Безопасные платежи в Интернете (3-D Secure)",
        "subTitle": "3-D Secure — технология, предназначенная для повышения безопасности расчетов"
    }, {
        "md5hash": "b6fa019f307d6a72951ab7268708aa15",
        "title": "Блокировка подозрительных операций",
        "subTitle": "На востребованные категории"
    }]
},
"frequentlyAskedQuestions": {
    "title": "Часто задаваемые вопросы",
    "list": [{
        "title": "Как повторно подключить подписку?",
        "description": "тест"
    }, {
        "title": "Как начисляются проценты?",
        "description": "тесттесттесттесттесттесттесттест"
    }, {
        "title": "Какие условия бесплатного обслуживания?",
        "description": ""
    }]
}
}
}
"""
    
static let validJsonWithEmptyFrequentlyAskedQuestions = """
{
    "statusCode": 200,
    "errorMessage": null,
    "data": {
    "id": "CARD_NAME_PRODUCT",
    "theme": "DEFAULT",
    "product": {
        "title": "Карта МИР «Все включено»",
        "image": "dict/getProductCatalogImage?image=/products/banners/car_collateral_loan.png",
        "features": [
            "кешбэк до 10 000 ₽ в месяц",
            "5% выгода при покупке топлива",
            "5% на категории сезона",
            "от 0,5% до 1% кешбэк на остальные покупки**"
        ],
        "discounts": {
            "title": "Скидки на переводы",
            "list": [{
                "md5hash": "b6fa019f307d6a72951ab7268708aa15",
                "title": "СБП"
            }, {
                "md5hash": "b6fa019f307d6a72951ab7268708aa15",
                "title": "За рубеж"
            }, {
                "md5hash": "b6fa019f307d6a72951ab7268708aa15",
                "title": "ЖКХ"
            }, {
                "md5hash": "b6fa019f307d6a72951ab7268708aa15",
                "title": "Налоги"
            }]
        }
    },
    "conditions": {
        "title": "Выгодные условия",
        "list": []
    },
    "security": {
        "title": "Безопасность",
        "list": [{
            "md5hash": "b6fa019f307d6a72951ab7268708aa15",
            "title": "Ваши средства застрахованы в АСВ",
            "subTitle": "Банк входит в систему страхования вкладов Агентства по страхованию вкладов"
        }, {
            "md5hash": "b6fa019f307d6a72951ab7268708aa15",
            "title": "Безопасные платежи в Интернете (3-D Secure)",
            "subTitle": "3-D Secure — технология, предназначенная для повышения безопасности расчетов"
        }, {
            "md5hash": "b6fa019f307d6a72951ab7268708aa15",
            "title": "Блокировка подозрительных операций",
            "subTitle": "На востребованные категории"
        }]
    },
    "frequentlyAskedQuestions": {
        "title": "Часто задаваемые вопросы",
        "list": []
    }
}
}
"""
}

private extension OrderCardLandingBackend.OrderCardLandingResponse {
    
    static let stub: Self = .init(
        theme: "DEFAULT",
        product: .init(
            title: "Карта МИР «Все включено»",
            image: "dict/getProductCatalogImage?image=/products/banners/car_collateral_loan.png",
            features: [
                "кешбэк до 10 000 ₽ в месяц",
                "5% выгода при покупке топлива",
                "5% на категории сезона",
                "от 0,5% до 1% кешбэк на остальные покупки**"
            ],
            discount: .init(
                title: "Скидки на переводы",
                list: [
                    .init(title: "СБП", md5hash: "b6fa019f307d6a72951ab7268708aa15"),
                    .init(title: "За рубеж", md5hash: "b6fa019f307d6a72951ab7268708aa15"),
                    .init(title: "ЖКХ", md5hash: "b6fa019f307d6a72951ab7268708aa15"),
                    .init(title: "Налоги", md5hash: "b6fa019f307d6a72951ab7268708aa15")
                ]
            )
        ),
        conditions: .init(
            title: "Выгодные условия",
            list: [
                .init(title: "0 ₽", subtitle: "Условия обслуживания", md5hash: "b6fa019f307d6a72951ab7268708aa15"),
                .init(title: "До 35%", subtitle: "Кешбэк и скидки", md5hash: "b6fa019f307d6a72951ab7268708aa15"),
                .init(title: "Кешбэк 5%", subtitle: "На востребованные категории", md5hash: "b6fa019f307d6a72951ab7268708aa15"),
                .init(title: "Кешбэк 5%", subtitle: "На топливо и 3% кешбэк на кофе", md5hash: "b6fa019f307d6a72951ab7268708aa15"),
                .init(title: "8% годовых", subtitle: "При сумме остатка от 500 001 ₽", md5hash: "b6fa019f307d6a72951ab7268708aa15")
            ]
        ),
        security: .init(
            title: "Безопасность",
            list: [
                .init(title: "Ваши средства застрахованы в АСВ", subtitle: "Банк входит в систему страхования вкладов Агентства по страхованию вкладов", md5hash: "b6fa019f307d6a72951ab7268708aa15"),
                .init(title: "Безопасные платежи в Интернете (3-D Secure)", subtitle: "3-D Secure — технология, предназначенная для повышения безопасности расчетов", md5hash: "b6fa019f307d6a72951ab7268708aa15"),
                .init(title: "Блокировка подозрительных операций", subtitle: "На востребованные категории", md5hash: "b6fa019f307d6a72951ab7268708aa15")
            ]
        ),
        frequentlyAskedQuestions: .init(
            title: "Часто задаваемые вопросы",
            list: [
                .init(title: "Как повторно подключить подписку?", md5hash: "тест"),
                .init(title: "Как начисляются проценты?", md5hash: "тесттесттесттесттесттесттесттест"),
                .init(title: "Какие условия бесплатного обслуживания?", md5hash: ""),
            ]
        )
    )
    
    static let stubWithEmptyConditions: Self = .init(
        theme: "DEFAULT",
        product: .init(
            title: "Карта МИР «Все включено»",
            image: "dict/getProductCatalogImage?image=/products/banners/car_collateral_loan.png",
            features: [
                "кешбэк до 10 000 ₽ в месяц",
                "5% выгода при покупке топлива",
                "5% на категории сезона",
                "от 0,5% до 1% кешбэк на остальные покупки**"
            ],
            discount: .init(
                title: "Скидки на переводы",
                list: [
                    .init(title: "СБП", md5hash: "b6fa019f307d6a72951ab7268708aa15"),
                    .init(title: "За рубеж", md5hash: "b6fa019f307d6a72951ab7268708aa15"),
                    .init(title: "ЖКХ", md5hash: "b6fa019f307d6a72951ab7268708aa15"),
                    .init(title: "Налоги", md5hash: "b6fa019f307d6a72951ab7268708aa15")
                ]
            )
        ),
        conditions: .init(
            title: "Выгодные условия",
            list: []
        ),
        security: .init(
            title: "Безопасность",
            list: [
                .init(title: "Ваши средства застрахованы в АСВ", subtitle: "Банк входит в систему страхования вкладов Агентства по страхованию вкладов", md5hash: "b6fa019f307d6a72951ab7268708aa15"),
                .init(title: "Безопасные платежи в Интернете (3-D Secure)", subtitle: "3-D Secure — технология, предназначенная для повышения безопасности расчетов", md5hash: "b6fa019f307d6a72951ab7268708aa15"),
                .init(title: "Блокировка подозрительных операций", subtitle: "На востребованные категории", md5hash: "b6fa019f307d6a72951ab7268708aa15")
            ]
        ),
        frequentlyAskedQuestions: .init(
            title: "Часто задаваемые вопросы",
            list: [
                .init(title: "Как повторно подключить подписку?", md5hash: "тест"),
                .init(title: "Как начисляются проценты?", md5hash: "тесттесттесттесттесттесттесттест"),
                .init(title: "Какие условия бесплатного обслуживания?", md5hash: ""),
            ]
        )
    )
    
    static let stubWithEmptySecurity: Self = .init(
        theme: "DEFAULT",
        product: .init(
            title: "Карта МИР «Все включено»",
            image: "dict/getProductCatalogImage?image=/products/banners/car_collateral_loan.png",
            features: [
                "кешбэк до 10 000 ₽ в месяц",
                "5% выгода при покупке топлива",
                "5% на категории сезона",
                "от 0,5% до 1% кешбэк на остальные покупки**"
            ],
            discount: .init(
                title: "Скидки на переводы",
                list: [
                    .init(title: "СБП", md5hash: "b6fa019f307d6a72951ab7268708aa15"),
                    .init(title: "За рубеж", md5hash: "b6fa019f307d6a72951ab7268708aa15"),
                    .init(title: "ЖКХ", md5hash: "b6fa019f307d6a72951ab7268708aa15"),
                    .init(title: "Налоги", md5hash: "b6fa019f307d6a72951ab7268708aa15")
                ]
            )
        ),
        conditions: .init(
            title: "Выгодные условия",
            list: [
                .init(title: "0 ₽", subtitle: "Условия обслуживания", md5hash: "b6fa019f307d6a72951ab7268708aa15"),
                .init(title: "До 35%", subtitle: "Кешбэк и скидки", md5hash: "b6fa019f307d6a72951ab7268708aa15"),
                .init(title: "Кешбэк 5%", subtitle: "На востребованные категории", md5hash: "b6fa019f307d6a72951ab7268708aa15"),
                .init(title: "Кешбэк 5%", subtitle: "На топливо и 3% кешбэк на кофе", md5hash: "b6fa019f307d6a72951ab7268708aa15"),
                .init(title: "8% годовых", subtitle: "При сумме остатка от 500 001 ₽", md5hash: "b6fa019f307d6a72951ab7268708aa15")
            ]
        ),
        security: .init(
            title: "Безопасность",
            list: []
        ),
        frequentlyAskedQuestions: .init(
            title: "Часто задаваемые вопросы",
            list: [
                .init(title: "Как повторно подключить подписку?", md5hash: "тест"),
                .init(title: "Как начисляются проценты?", md5hash: "тесттесттесттесттесттесттесттест"),
                .init(title: "Какие условия бесплатного обслуживания?", md5hash: ""),
            ]
        )
    )
    
    static let stubWithEmptyQuestion: Self = .init(
        theme: "DEFAULT",
        product: .init(
            title: "Карта МИР «Все включено»",
            image: "dict/getProductCatalogImage?image=/products/banners/car_collateral_loan.png",
            features: [
                "кешбэк до 10 000 ₽ в месяц",
                "5% выгода при покупке топлива",
                "5% на категории сезона",
                "от 0,5% до 1% кешбэк на остальные покупки**"
            ],
            discount: .init(
                title: "Скидки на переводы",
                list: [
                    .init(title: "СБП", md5hash: "b6fa019f307d6a72951ab7268708aa15"),
                    .init(title: "За рубеж", md5hash: "b6fa019f307d6a72951ab7268708aa15"),
                    .init(title: "ЖКХ", md5hash: "b6fa019f307d6a72951ab7268708aa15"),
                    .init(title: "Налоги", md5hash: "b6fa019f307d6a72951ab7268708aa15")
                ]
            )
        ),
        conditions: .init(
            title: "Выгодные условия",
            list: [
                .init(title: "0 ₽", subtitle: "Условия обслуживания", md5hash: "b6fa019f307d6a72951ab7268708aa15"),
                .init(title: "До 35%", subtitle: "Кешбэк и скидки", md5hash: "b6fa019f307d6a72951ab7268708aa15"),
                .init(title: "Кешбэк 5%", subtitle: "На востребованные категории", md5hash: "b6fa019f307d6a72951ab7268708aa15"),
                .init(title: "Кешбэк 5%", subtitle: "На топливо и 3% кешбэк на кофе", md5hash: "b6fa019f307d6a72951ab7268708aa15"),
                .init(title: "8% годовых", subtitle: "При сумме остатка от 500 001 ₽", md5hash: "b6fa019f307d6a72951ab7268708aa15")
            ]
        ),
        security: .init(
            title: "Безопасность",
            list: [
                .init(title: "Ваши средства застрахованы в АСВ", subtitle: "Банк входит в систему страхования вкладов Агентства по страхованию вкладов", md5hash: "b6fa019f307d6a72951ab7268708aa15"),
                .init(title: "Безопасные платежи в Интернете (3-D Secure)", subtitle: "3-D Secure — технология, предназначенная для повышения безопасности расчетов", md5hash: "b6fa019f307d6a72951ab7268708aa15"),
                .init(title: "Блокировка подозрительных операций", subtitle: "На востребованные категории", md5hash: "b6fa019f307d6a72951ab7268708aa15")
            ]
        ),
        frequentlyAskedQuestions: .init(
            title: "Часто задаваемые вопросы",
            list: []
        )
    )
}
