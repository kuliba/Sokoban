//
//  ResponseMapper+mapCreateCreditCardLandingAndApplicationResponseTests.swift
//
//
//  Created by Igor Malyarov on 29.03.2025.
//

extension ResponseMapper {
    
    struct CreateCreditCardLandingAndApplication: Equatable {
        
        let theme: String
        let header: Header?
        let banner: Banner
    }
}

extension ResponseMapper.CreateCreditCardLandingAndApplication {
    
    struct Header: Equatable {
        
        let title: String
        let subtitle: String
    }
    
    struct Banner: Equatable {
        
        let background: String
        let conditions: [String]
    }
}

extension ResponseMapper {
    
    static func mapCreateCreditCardLandingAndApplicationResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> MappingResult<CreateCreditCardLandingAndApplication> {
        
        map(data, httpURLResponse, mapOrThrow: CreateCreditCardLandingAndApplication.init(data:))
    }
}

private extension ResponseMapper.CreateCreditCardLandingAndApplication {
    
    init(data: ResponseMapper._DTO) throws {
        
        guard let theme = data.theme,
              let banner = data._banner
        else { throw ResponseFailure() }
        
        self.init(
            theme: theme,
            header: data._header,
            banner: banner
        )
    }
    
    struct ResponseFailure: Error {}
}

// MARK: - Mapping

private extension ResponseMapper._DTO {
    
    typealias Response = ResponseMapper.CreateCreditCardLandingAndApplication
    
    var _banner: Response.Banner? {
        
        guard let background = banner?.background
        else { return nil }
        
        let conditions = banner?.highlightedOfferConditions ?? []
        
        return .init(background: background, conditions: conditions)
    }
    
    var _header: Response.Header? {
        
        guard let title = header?.title,
              let subtitle = header?.subtitle
        else { return nil }
        
        return .init(title: title, subtitle: subtitle)
    }
}

// MARK: - DTO

private extension ResponseMapper {
    
    struct _DTO: Decodable {
        
        let theme: String?
        let header: _Header?
        let banner: _Banner?
    }
}

extension ResponseMapper._DTO {
    
    struct _Header: Decodable {
        
        let title: String?
        let subtitle: String?
    }
    
    struct _Banner: Decodable {
        
        let background: String?
        let highlightedOfferConditions: [String]?
    }
}

import CreditCardMVPBackend
import RemoteServices
import XCTest

final class ResponseMapper_mapCreateCreditCardLandingAndApplicationResponseTests: XCTestCase {
    
    func test_map_shouldDeliverInvalidFailure_onEmptyData() {
        
        let emptyData: Data = .empty
        
        XCTAssertNoDiff(
            map(emptyData),
            .failure(.invalid(statusCode: 200, data: emptyData))
        )
    }
    
    func test_map_shouldDeliverInvalidFailure_onInvalidData() {
        
        assert(json: .invalidData, delivers: .invalid(
            statusCode: 200,
            data: .invalidData
        ))
    }
    
    func test_map_shouldDeliverInvalidFailure_onEmptyJSON() {
        
        assert(json: .emptyJSON, delivers: .invalid(
            statusCode: 200,
            data: .emptyJSON
        ))
    }
    
    func test_map_shouldDeliverInvalidFailure_onEmptyDataResponse() {
        
        assert(json: .emptyDataResponse, delivers: .invalid(
            statusCode: 200,
            data: .emptyDataResponse
        ))
    }
    
    func test_map_shouldDeliverInvalidFailure_onNullServerResponse() {
        
        assert(json: .nullServerResponse, delivers: .invalid(
            statusCode: 200,
            data: .nullServerResponse
        ))
    }
    
    func test_map_shouldDeliverServerError_onServerError() {
        
        assert(json: .serverError, delivers: .server(
            statusCode: 102,
            errorMessage: "Возникла техническая ошибка"
        ))
    }
    
    func test_map_shouldDeliverInvalidFailure_onNonOkHTTPResponse() {
        
        for statusCode in [199, 201, 399, 400, 401, 404] {
            
            let json = String.validData()
            let validData = json.json
            let nonOkResponse = anyHTTPURLResponse(statusCode: statusCode)
            
            assert(
                json: json,
                httpURLResponse: nonOkResponse,
                delivers: .invalid(statusCode: statusCode, data: validData)
            )
        }
    }
    
    func test_map_shouldDeliverResponse_onValidData() throws {
        
        assert(json: .validData(), delivers: makeResponse())
    }
    
    func test_map_shouldDeliverFailure_onResponseWithoutTheme() throws {
        
        assert(
            json: .withMissingTheme,
            delivers: .invalid(statusCode: 200, data: String.withMissingTheme.json)
        )
    }
    
    func test_map_shouldDeliverResponseWithTheme() throws {
        
        let theme = anyMessage()
        
        assert(
            json: .validData(theme: theme),
            delivers: makeResponse(theme: theme)
        )
    }
    
    func test_map_shouldDeliverResponseWithoutHeader_onMissingHeaderTitle() throws {
        
        assert(
            json: .withMissingHeaderTitle,
            delivers: makeResponse(header: nil)
        )
    }
    
    func test_map_shouldDeliverResponseWithHeaderTitle() throws {
        
        let headerTitle = anyMessage()
        
        assert(
            json: .validData(headerTitle: headerTitle),
            delivers: makeResponse(headerTitle: headerTitle)
        )
    }
    
    func test_map_shouldDeliverResponseWithHeaderSubtitle() throws {
        
        let headerSubtitle = anyMessage()
        
        assert(
            json: .validData(headerSubtitle: headerSubtitle),
            delivers: makeResponse(headerSubtitle: headerSubtitle)
        )
    }
    
    func test_map_shouldDeliverFailure_onMissingBannerBackground() throws {
        
        assert(
            json: .withMissingBannerBackground,
            delivers: .invalid(statusCode: 200, data: String.withMissingBannerBackground.json)
        )
    }
    
    func test_map_shouldDeliverResponseWithBannerBackground() throws {
        
        let bannerBackground = anyMessage()
        
        assert(
            json: .validData(bannerBackground: bannerBackground),
            delivers: makeResponse(bannerBackground: bannerBackground)
        )
    }
    
    func test_map_shouldDeliverResponseWithEmptyHighlightedOfferConditions_onMissingBannerConditions() throws {
        
        assert(
            json: .withMissingHighlightedOfferConditions,
            delivers: makeResponse(bannerConditions: [])
        )
    }
    
    func test_map_shouldDeliverResponseWithHighlightedOfferCondition() throws {
        
        let condition = anyMessage()
        
        assert(
            json: .validData(conditions: [condition]),
            delivers: makeResponse(bannerConditions: [condition])
        )
    }
    
    func test_map_shouldDeliverResponseWithHighlightedOfferConditions() throws {
        
        let (condition1, condition2) = (anyMessage(), anyMessage())
        
        assert(
            json: .validData(conditions: [condition1, condition2]),
            delivers: makeResponse(bannerConditions: [condition1, condition2])
        )
    }
    
    // MARK: - Helpers
    
    private typealias Response = ResponseMapper.CreateCreditCardLandingAndApplication
    private typealias MappingResult = ResponseMapper.MappingResult<Response>
    
    private func map(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse = anyHTTPURLResponse()
    ) -> MappingResult {
        
        ResponseMapper.mapCreateCreditCardLandingAndApplicationResponse(data, httpURLResponse)
    }
    
    private func makeResponse(
        theme: String = "DEFAULT",
        header: Response.Header?,
        banner: Response.Banner? = nil
    ) -> Response {
        
        return .init(
            theme: theme,
            header: header,
            banner: banner ?? makeBanner()
        )
    }
    
    private func makeBanner(
        background: String = "dict/getProductCatalogImage?image=products/pages/order-credit-card/landing/images/digital_card_landing_bg.png",
        conditions: [String] = [
            "Вам одобрена сумма 97 000 ₽",
            "Предложение действует до 30.04.2025"
        ]
    ) -> Response.Banner {
        
        return .init(background: background, conditions: conditions)
    }
    
    private func makeResponse(
        theme: String = "DEFAULT",
        headerTitle: String = "Кредитная карта",
        headerSubtitle: String = "«Все включено»",
        bannerBackground: String = "dict/getProductCatalogImage?image=products/pages/order-credit-card/landing/images/digital_card_landing_bg.png",
        bannerConditions: [String] = [
            "Вам одобрена сумма 97 000 ₽",
            "Предложение действует до 30.04.2025"
        ]
    ) -> Response {
        
        return .init(
            theme: theme,
            header: .init(
                title: headerTitle,
                subtitle: headerSubtitle
            ),
            banner: .init(
                background: bannerBackground,
                conditions: bannerConditions
            )
        )
    }
    
    private func assert(
        json: String,
        httpURLResponse: HTTPURLResponse = anyHTTPURLResponse(),
        delivers response: Response,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertNoDiff(map(.init(json.utf8), httpURLResponse), .success(response), file: file, line: line)
    }
    
    private func assert(
        json: String,
        httpURLResponse: HTTPURLResponse = anyHTTPURLResponse(),
        delivers failure: ResponseMapper.MappingError,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertNoDiff(map(.init(json.utf8), httpURLResponse), .failure(failure), file: file, line: line)
    }
}

private extension Data {
    
    static let empty: Data = .init()
    static let invalidData: Data = String.invalidData.json
    static let emptyJSON: Data = String.emptyJSON.json
    static let emptyDataResponse: Data = String.emptyDataResponse.json
    static let nullServerResponse: Data = String.nullServerResponse.json
    static let serverError: Data = String.serverError.json
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
    
    static func validData(
        theme: String = "DEFAULT",
        headerTitle: String = "Кредитная карта",
        headerSubtitle: String = "«Все включено»",
        bannerBackground: String = "dict/getProductCatalogImage?image=products/pages/order-credit-card/landing/images/digital_card_landing_bg.png",
        conditions: [String] = [
            "Вам одобрена сумма 97 000 ₽",
            "Предложение действует до 30.04.2025"
        ]
    ) -> String {
        
"""
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "theme": "\(theme)",
    "header": {
      "title": "\(headerTitle)",
      "subtitle": "\(headerSubtitle)"
    },
    "banner": {
      "background": "\(bannerBackground)",
      "highlightedOfferConditions": \(conditions)
    },
    "offerConditions": {
      "title": "Персональное предложение",
      "list": [
        {
          "md5hash": "b6fa019f307d6a72951ab7268708aa15",
          "title": "Процентная ставка",
          "subTitle": "6,5 % годовых"
        },
        {
          "md5hash": "b6fa019f307d6a72951ab7268708aa15",
          "title": "Срок льготного периода",
          "subTitle": "До 62 дней"
        },
        {
          "md5hash": "b6fa019f307d6a72951ab7268708aa15",
          "title": "Стоимость обслуживания",
          "subTitle": "Бесплатно навсегда"
        },
        {
          "md5hash": "b6fa019f307d6a72951ab7268708aa15",
          "title": "Оформление",
          "subTitle": "В отделении Банка"
        }
      ]
    },
    "frequentlyAskedQuestions": {
      "title": "Часто задаваемые вопросы",
      "list": [
        {
          "title": "Как повторно подключить подписку?",
          "description": "тест"
        },
        {
          "title": "Как начисляются проценты?",
          "description": "тесттесттесттесттесттесттесттест"
        },
        {
          "title": "Какие условия бесплатного обслуживания?",
          "description": ""
        }
      ]
    },
    "consent": {
      "terms": "https://www.forabank.ru/dkbo/dkbo.pdf",
      "tariffs": "https://www.forabank.ru/tarify/",
      "creditHistoryRequest": "https://www.forabank.ru/user-upload/dok-dbo-fl/coglasie-na-zapros-v-bki.pdf"
    },
    "application": {
      "id": 123456789,
      "status": "DRAFT"
    },
    "offer": {
      "id": "123",
      "gracePeriod": "36",
      "tarifPlanRate": "69.99",
      "offerPeriodValidity": "2025-03-31",
      "offerLimitAmount": "10000.00",
      "tarifPlanName": "ТП1",
      "icon": "37baa2ff94fb468f65fa0ea4017bf44a"
    }
  }
}
"""
    }
    
    static let withMissingHeaderTitle = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "theme": "DEFAULT",
    "header": {
      "subtitle": "«Все включено»"
    },
    "banner": {
      "background": "dict/getProductCatalogImage?image=products/pages/order-credit-card/landing/images/digital_card_landing_bg.png",
      "highlightedOfferConditions": [
        "Вам одобрена сумма 97 000 ₽",
        "Предложение действует до 30.04.2025"
      ]
    },
    "offerConditions": {
      "title": "Персональное предложение",
      "list": [
        {
          "md5hash": "b6fa019f307d6a72951ab7268708aa15",
          "title": "Процентная ставка",
          "subTitle": "6,5 % годовых"
        },
        {
          "md5hash": "b6fa019f307d6a72951ab7268708aa15",
          "title": "Срок льготного периода",
          "subTitle": "До 62 дней"
        },
        {
          "md5hash": "b6fa019f307d6a72951ab7268708aa15",
          "title": "Стоимость обслуживания",
          "subTitle": "Бесплатно навсегда"
        },
        {
          "md5hash": "b6fa019f307d6a72951ab7268708aa15",
          "title": "Оформление",
          "subTitle": "В отделении Банка"
        }
      ]
    },
    "frequentlyAskedQuestions": {
      "title": "Часто задаваемые вопросы",
      "list": [
        {
          "title": "Как повторно подключить подписку?",
          "description": "тест"
        },
        {
          "title": "Как начисляются проценты?",
          "description": "тесттесттесттесттесттесттесттест"
        },
        {
          "title": "Какие условия бесплатного обслуживания?",
          "description": ""
        }
      ]
    },
    "consent": {
      "terms": "https://www.forabank.ru/dkbo/dkbo.pdf",
      "tariffs": "https://www.forabank.ru/tarify/",
      "creditHistoryRequest": "https://www.forabank.ru/user-upload/dok-dbo-fl/coglasie-na-zapros-v-bki.pdf"
    },
    "application": {
      "id": 123456789,
      "status": "DRAFT"
    },
    "offer": {
      "id": "123",
      "gracePeriod": "36",
      "tarifPlanRate": "69.99",
      "offerPeriodValidity": "2025-03-31",
      "offerLimitAmount": "10000.00",
      "tarifPlanName": "ТП1",
      "icon": "37baa2ff94fb468f65fa0ea4017bf44a"
    }
  }
}
"""
    
    static let withMissingHighlightedOfferConditions = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "theme": "DEFAULT",
    "header": {
      "title": "Кредитная карта",
      "subtitle": "«Все включено»"
    },
    "banner": {
      "background": "dict/getProductCatalogImage?image=products/pages/order-credit-card/landing/images/digital_card_landing_bg.png"
    },
    "offerConditions": {
      "title": "Персональное предложение",
      "list": [
        {
          "md5hash": "b6fa019f307d6a72951ab7268708aa15",
          "title": "Процентная ставка",
          "subTitle": "6,5 % годовых"
        },
        {
          "md5hash": "b6fa019f307d6a72951ab7268708aa15",
          "title": "Срок льготного периода",
          "subTitle": "До 62 дней"
        },
        {
          "md5hash": "b6fa019f307d6a72951ab7268708aa15",
          "title": "Стоимость обслуживания",
          "subTitle": "Бесплатно навсегда"
        },
        {
          "md5hash": "b6fa019f307d6a72951ab7268708aa15",
          "title": "Оформление",
          "subTitle": "В отделении Банка"
        }
      ]
    },
    "frequentlyAskedQuestions": {
      "title": "Часто задаваемые вопросы",
      "list": [
        {
          "title": "Как повторно подключить подписку?",
          "description": "тест"
        },
        {
          "title": "Как начисляются проценты?",
          "description": "тесттесттесттесттесттесттесттест"
        },
        {
          "title": "Какие условия бесплатного обслуживания?",
          "description": ""
        }
      ]
    },
    "consent": {
      "terms": "https://www.forabank.ru/dkbo/dkbo.pdf",
      "tariffs": "https://www.forabank.ru/tarify/",
      "creditHistoryRequest": "https://www.forabank.ru/user-upload/dok-dbo-fl/coglasie-na-zapros-v-bki.pdf"
    },
    "application": {
      "id": 123456789,
      "status": "DRAFT"
    },
    "offer": {
      "id": "123",
      "gracePeriod": "36",
      "tarifPlanRate": "69.99",
      "offerPeriodValidity": "2025-03-31",
      "offerLimitAmount": "10000.00",
      "tarifPlanName": "ТП1",
      "icon": "37baa2ff94fb468f65fa0ea4017bf44a"
    }
  }
}
"""
    
    static let withMissingTheme = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "header": {
      "title": "Кредитная карта",
      "subtitle": "«Все включено»"
    },
    "banner": {
      "background": "dict/getProductCatalogImage?image=products/pages/order-credit-card/landing/images/digital_card_landing_bg.png",
      "highlightedOfferConditions": [
        "Вам одобрена сумма 97 000 ₽",
        "Предложение действует до 30.04.2025"
      ]
    },
    "offerConditions": {
      "title": "Персональное предложение",
      "list": [
        {
          "md5hash": "b6fa019f307d6a72951ab7268708aa15",
          "title": "Процентная ставка",
          "subTitle": "6,5 % годовых"
        },
        {
          "md5hash": "b6fa019f307d6a72951ab7268708aa15",
          "title": "Срок льготного периода",
          "subTitle": "До 62 дней"
        },
        {
          "md5hash": "b6fa019f307d6a72951ab7268708aa15",
          "title": "Стоимость обслуживания",
          "subTitle": "Бесплатно навсегда"
        },
        {
          "md5hash": "b6fa019f307d6a72951ab7268708aa15",
          "title": "Оформление",
          "subTitle": "В отделении Банка"
        }
      ]
    },
    "frequentlyAskedQuestions": {
      "title": "Часто задаваемые вопросы",
      "list": [
        {
          "title": "Как повторно подключить подписку?",
          "description": "тест"
        },
        {
          "title": "Как начисляются проценты?",
          "description": "тесттесттесттесттесттесттесттест"
        },
        {
          "title": "Какие условия бесплатного обслуживания?",
          "description": ""
        }
      ]
    },
    "consent": {
      "terms": "https://www.forabank.ru/dkbo/dkbo.pdf",
      "tariffs": "https://www.forabank.ru/tarify/",
      "creditHistoryRequest": "https://www.forabank.ru/user-upload/dok-dbo-fl/coglasie-na-zapros-v-bki.pdf"
    },
    "application": {
      "id": 123456789,
      "status": "DRAFT"
    },
    "offer": {
      "id": "123",
      "gracePeriod": "36",
      "tarifPlanRate": "69.99",
      "offerPeriodValidity": "2025-03-31",
      "offerLimitAmount": "10000.00",
      "tarifPlanName": "ТП1",
      "icon": "37baa2ff94fb468f65fa0ea4017bf44a"
    }
  }
}
"""
    
    static let withMissingBannerBackground = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "theme": "DEFAULT",
    "header": {
      "title": "Кредитная карта",
      "subtitle": "«Все включено»"
    },
    "banner": {
      "highlightedOfferConditions": [
        "Вам одобрена сумма 97 000 ₽",
        "Предложение действует до 30.04.2025"
      ]
    },
    "offerConditions": {
      "title": "Персональное предложение",
      "list": [
        {
          "md5hash": "b6fa019f307d6a72951ab7268708aa15",
          "title": "Процентная ставка",
          "subTitle": "6,5 % годовых"
        },
        {
          "md5hash": "b6fa019f307d6a72951ab7268708aa15",
          "title": "Срок льготного периода",
          "subTitle": "До 62 дней"
        },
        {
          "md5hash": "b6fa019f307d6a72951ab7268708aa15",
          "title": "Стоимость обслуживания",
          "subTitle": "Бесплатно навсегда"
        },
        {
          "md5hash": "b6fa019f307d6a72951ab7268708aa15",
          "title": "Оформление",
          "subTitle": "В отделении Банка"
        }
      ]
    },
    "frequentlyAskedQuestions": {
      "title": "Часто задаваемые вопросы",
      "list": [
        {
          "title": "Как повторно подключить подписку?",
          "description": "тест"
        },
        {
          "title": "Как начисляются проценты?",
          "description": "тесттесттесттесттесттесттесттест"
        },
        {
          "title": "Какие условия бесплатного обслуживания?",
          "description": ""
        }
      ]
    },
    "consent": {
      "terms": "https://www.forabank.ru/dkbo/dkbo.pdf",
      "tariffs": "https://www.forabank.ru/tarify/",
      "creditHistoryRequest": "https://www.forabank.ru/user-upload/dok-dbo-fl/coglasie-na-zapros-v-bki.pdf"
    },
    "application": {
      "id": 123456789,
      "status": "DRAFT"
    },
    "offer": {
      "id": "123",
      "gracePeriod": "36",
      "tarifPlanRate": "69.99",
      "offerPeriodValidity": "2025-03-31",
      "offerLimitAmount": "10000.00",
      "tarifPlanName": "ТП1",
      "icon": "37baa2ff94fb468f65fa0ea4017bf44a"
    }
  }
}
"""
    
    static let _source = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "theme": "DEFAULT",
    "header": {
      "title": "Кредитная карта",
      "subtitle": "«Все включено»"
    },
    "banner": {
      "background": "dict/getProductCatalogImage?image=products/pages/order-credit-card/landing/images/digital_card_landing_bg.png",
      "highlightedOfferConditions": [
        "Вам одобрена сумма 97 000 ₽",
        "Предложение действует до 30.04.2025"
      ]
    },
    "offerConditions": {
      "title": "Персональное предложение",
      "list": [
        {
          "md5hash": "b6fa019f307d6a72951ab7268708aa15",
          "title": "Процентная ставка",
          "subTitle": "6,5 % годовых"
        },
        {
          "md5hash": "b6fa019f307d6a72951ab7268708aa15",
          "title": "Срок льготного периода",
          "subTitle": "До 62 дней"
        },
        {
          "md5hash": "b6fa019f307d6a72951ab7268708aa15",
          "title": "Стоимость обслуживания",
          "subTitle": "Бесплатно навсегда"
        },
        {
          "md5hash": "b6fa019f307d6a72951ab7268708aa15",
          "title": "Оформление",
          "subTitle": "В отделении Банка"
        }
      ]
    },
    "frequentlyAskedQuestions": {
      "title": "Часто задаваемые вопросы",
      "list": [
        {
          "title": "Как повторно подключить подписку?",
          "description": "тест"
        },
        {
          "title": "Как начисляются проценты?",
          "description": "тесттесттесттесттесттесттесттест"
        },
        {
          "title": "Какие условия бесплатного обслуживания?",
          "description": ""
        }
      ]
    },
    "consent": {
      "terms": "https://www.forabank.ru/dkbo/dkbo.pdf",
      "tariffs": "https://www.forabank.ru/tarify/",
      "creditHistoryRequest": "https://www.forabank.ru/user-upload/dok-dbo-fl/coglasie-na-zapros-v-bki.pdf"
    },
    "application": {
      "id": 123456789,
      "status": "DRAFT"
    },
    "offer": {
      "id": "123",
      "gracePeriod": "36",
      "tarifPlanRate": "69.99",
      "offerPeriodValidity": "2025-03-31",
      "offerLimitAmount": "10000.00",
      "tarifPlanName": "ТП1",
      "icon": "37baa2ff94fb468f65fa0ea4017bf44a"
    }
  }
}
"""
}
