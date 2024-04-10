//
//  ResponseMapper+mapGetC2BSubResponseTests.swift
//
//
//  Created by Igor Malyarov on 28.12.2023.
//

import FastPaymentsSettings
import RemoteServices
import XCTest

final class ResponseMapper_mapGetC2BSubResponseResponseTests: XCTestCase {
    
    func test_map_shouldDeliverInvalidErrorOnInvalidData() throws {
        
        let invalidData = anyData()
        
        let result = map(invalidData)
        
        assert(result, equals: .failure(.invalid(
            statusCode: 200,
            data: invalidData
        )))
    }
    
    func test_map_shouldDeliverServerErrorOnDataWithServerErrorWithOkHTTPURLResponseStatusCode() throws {
        
        let okResponse = anyHTTPURLResponse(statusCode: 200)
        let result = map(jsonWithServerError(), okResponse)
        
        assert(result, equals: .failure(.server(
            statusCode: 102,
            errorMessage: "Возникла техническая ошибка"
        )))
    }
    
    func test_map_shouldDeliverServerErrorOnDataWithServerErrorWithNonOkHTTPURLResponseStatusCode() throws {
        
        let nonOkResponse = anyHTTPURLResponse(statusCode: 400)
        let result = map(jsonWithServerError(), nonOkResponse)
        
        assert(result, equals: .failure(.server(
            statusCode: 102,
            errorMessage: "Возникла техническая ошибка"
        )))
    }
    
    func test_map_shouldDeliverInvalidOnNonOkHTTPURLResponseStatusCode() throws {
        
        let statusCode = 400
        let data = anyData()
        let nonOkResponse = anyHTTPURLResponse(statusCode: statusCode)
        let result = map(data, nonOkResponse)
        
        assert(result, equals: .failure(.invalid(
            statusCode: statusCode,
            data: data
        )))
    }
    
    func test_map_shouldDeliverInvalidOnNonOkHTTPURLResponseStatusCodeWithBadData() throws {
        
        let badData = Data(jsonStringWithBadData.utf8)
        let statusCode = 400
        let nonOkResponse = anyHTTPURLResponse(statusCode: statusCode)
        let result = map(badData, nonOkResponse)
        
        assert(result, equals: .failure(.invalid(
            statusCode: statusCode,
            data: badData
        )))
    }
    
    func test_map_shouldDeliverResponseOnOkHTTPURLResponseStatusCodeWithValidData_j1() throws {
        
        let validData = Data(jsonString_j1.utf8)
        let result = map(validData)
        
        assert(result, equals: .success(.j1))
    }
    
    func test_map_shouldDeliverResponseOnOkHTTPURLResponseStatusCodeWithValidData_j2() throws {
        
        let validData = Data(jsonString_j2.utf8)
        let result = map(validData)
        
        assert(result, equals: .success(.j2))
    }
    
    // MARK: - Helpers
    
    private func map(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse = anyHTTPURLResponse()
    ) -> ResponseMapper.MappingResult<GetC2BSubscription> {
        
        ResponseMapper.mapGetC2BSubResponseResponse(data, httpURLResponse)
    }
}

private extension GetC2BSubscription {
    
    static let j1: Self = .init(
        title: "Управление подписками",
        subscriptionType: .control,
        emptyList: [
            "У Вас нет активных подписок.",
            "Для активации перейдите в приложения ваших любимых магазинов и активируйте привязку счета.",
            "Деньги в таком случае будут списываться автоматически."
        ],
        emptySearch: "Нет совпадений",
        list: [.init(
            productId: "10000198241",
            productType: .card,
            productTitle: "Карта списания",
            subscription: [.init(
                subscriptionToken: "161fda956d884cf5b836d5642452044b",
                brandIcon: "b8b31e25a275e3f04ae189f4a538536a",
                brandName: "Цветы  у дома",
                subscriptionPurpose: "Функциональная ссылка для теста №563",
                cancelAlert: "Вы действительно хотите отключить подписку Цветы  у дома?"
            )]
        )]
    )
    
    static let j2: Self = .init(
        title: "Управление подписками",
        subscriptionType: .empty,
        emptyList: [
            "У Вас нет активных подписок.",
            "Для активации перейдите в приложения ваших любимых магазинов и активируйте привязку счета.",
            "Деньги в таком случае будут списываться автоматически."
        ],
        emptySearch: nil,
        list: nil
    )
}

private let jsonString_j1 = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "title": "Управление подписками",
    "subscriptionType": "SUBSCRIPTION_CONTROL",
    "emptyList": [
      "У Вас нет активных подписок.",
      "Для активации перейдите в приложения ваших любимых магазинов и активируйте привязку счета.",
      "Деньги в таком случае будут списываться автоматически."
    ],
    "emptySearch": "Нет совпадений",
    "list": [
      {
        "productId": "10000198241",
        "productType": "CARD",
        "productTitle": "Карта списания",
        "subscription": [
          {
            "subscriptionToken": "161fda956d884cf5b836d5642452044b",
            "brandIcon": "b8b31e25a275e3f04ae189f4a538536a",
            "brandName": "Цветы  у дома",
            "subscriptionPurpose": "Функциональная ссылка для теста №563",
            "cancelAlert": "Вы действительно хотите отключить подписку Цветы  у дома?"
          }
        ]
      }
    ]
  }
}
"""

private let jsonString_j2 = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "title": "Управление подписками",
    "subscriptionType": "SUBSCRIPTION_EMPTY",
    "emptyList": [
      "У Вас нет активных подписок.",
      "Для активации перейдите в приложения ваших любимых магазинов и активируйте привязку счета.",
      "Деньги в таком случае будут списываться автоматически."
    ]
  }
}
"""
