//
//  ResponseMapper+mapGetC2BSubResponseTests.swift
//
//
//  Created by Igor Malyarov on 28.12.2023.
//

import Foundation

/// - Warning: this data type resembles deficiencies of the backend data type. Could be improved.
struct GetC2BSubResponse: Equatable {
    
    let title: String
    let subscriptionType: SubscriptionType
    let emptyList: [String]?
    let emptySearch: String?
    let list: [ProductSubscription]?
    
    init(
        title: String,
        subscriptionType: SubscriptionType,
        emptyList: [String]? = nil,
        emptySearch: String? = nil,
        list: [ProductSubscription]? = nil
    ) {
        self.title = title
        self.subscriptionType = subscriptionType
        self.emptyList = emptyList
        self.emptySearch = emptySearch
        self.list = list
    }
    
    enum SubscriptionType: Equatable {
        
        case control, empty
    }
    
    struct ProductSubscription: Equatable {
        
        let productId: String
        let productType: ProductType
        let productTitle: String
        let subscription: [Subscription]
        
        enum ProductType: Equatable {
            
            case account, card
        }
        
        struct Subscription: Equatable {
            
            let subscriptionToken: String
            let brandIcon: String
            let brandName: String
            let subscriptionPurpose: String
            let cancelAlert: String
        }
    }
}

extension ResponseMapper {
    
    typealias GetC2BSubResponseResult = Result<GetC2BSubResponse, MappingError>
    
    static func mapGetC2BSubResponseResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> GetC2BSubResponseResult {
        
        map(data, httpURLResponse, map: map)
    }
    
    private static func map(
        _ data: _Data
    ) throws -> GetC2BSubResponse {
        
        data.getC2BSubResponse
    }
}

private extension ResponseMapper._Data {
    
    var getC2BSubResponse: GetC2BSubResponse {
        
        .init(
            title: title,
            subscriptionType: subscriptionType.dto,
            emptyList: emptyList,
            emptySearch: emptySearch,
            list: list?.map(\.dto)
        )
    }
}

private extension ResponseMapper._Data.SubscriptionType {
    
    var dto: GetC2BSubResponse.SubscriptionType {
        
        switch self {
        case .control: return .control
        case .empty:   return .empty
        }
    }
}

private extension ResponseMapper._Data.ProductSubscription {
    
    var dto: GetC2BSubResponse.ProductSubscription {
        
        .init(
            productId: productId,
            productType: productType.dto,
            productTitle: productTitle,
            subscription: subscription.map(\.dto)
        )
    }
}

private extension ResponseMapper._Data.ProductSubscription.ProductType {
    
    var dto: GetC2BSubResponse.ProductSubscription.ProductType {
        
        switch self {
        case .account: return .account
        case .card:    return .card
        }
    }
}

private extension ResponseMapper._Data.ProductSubscription.Subscription {
    
    var dto: GetC2BSubResponse.ProductSubscription.Subscription {
        
        .init(
            subscriptionToken: subscriptionToken,
            brandIcon: brandIcon,
            brandName: brandName,
            subscriptionPurpose: subscriptionPurpose,
            cancelAlert: cancelAlert
        )
    }
}

private extension ResponseMapper {
    
    struct _Data: Decodable {
        
        let title: String
        let subscriptionType: SubscriptionType
        let emptyList: [String]?
        let emptySearch: String?
        let list: [ProductSubscription]?
        
        enum SubscriptionType: String, Decodable {
            
            case control = "SUBSCRIPTION_CONTROL"
            case empty = "SUBSCRIPTION_EMPTY"
        }
        
        struct ProductSubscription: Decodable {
            
            let productId: String
            let productType: ProductType
            let productTitle: String
            let subscription: [Subscription]
            
            enum ProductType: String, Decodable {
                
                case account = "ACCOUNT"
                case card = "CARD"
            }
            
            struct Subscription: Decodable {
                
                let subscriptionToken: String
                let brandIcon: String
                let brandName: String
                let subscriptionPurpose: String
                let cancelAlert: String
            }
        }
    }
}

import FastPaymentsSettings
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
    ) -> ResponseMapper.GetC2BSubResponseResult {
        
        ResponseMapper.mapGetC2BSubResponseResponse(data, httpURLResponse)
    }
}

private extension GetC2BSubResponse {
    
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

private extension ResponseMapper._Data {
    
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
            productId: "10000128973",
            productType: .account,
            productTitle: "Счет списания",
            subscription: [.init(
                subscriptionToken: "999c04f9e51b4911abdd9a32961c763d",
                brandIcon: "4654846855",
                brandName: "Цветы у дома",
                subscriptionPurpose: "Подписка на получение QR для теста 560",
                cancelAlert: "Вы действительно хотите отключить подписку Цветы у дома?"
            )]
        )]
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
