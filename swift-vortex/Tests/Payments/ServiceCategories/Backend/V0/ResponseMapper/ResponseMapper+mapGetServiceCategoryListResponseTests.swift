//
//  ResponseMapper+mapGetServiceCategoryListResponseTests.swift
//
//
//  Created by Igor Malyarov on 13.08.2024.
//

import ServiceCategoriesBackendV0
import RemoteServices
import XCTest

final class ResponseMapper_mapGetServiceCategoryListResponseTests: XCTestCase {
    
    func test_map_shouldDeliverInvalidFailureOnEmptyData() {
        
        let emptyData: Data = .empty
        
        XCTAssertNoDiff(
            map(emptyData),
            .failure(.invalid(statusCode: 200, data: emptyData))
        )
    }
    
    func test_map_shouldDeliverInvalidFailureOnInvalidData() {
        
        let invalidData: Data = .invalidData
        
        XCTAssertNoDiff(
            map(invalidData),
            .failure(.invalid(statusCode: 200, data: invalidData))
        )
    }
    
    func test_map_shouldDeliverInvalidFailureOnEmptyJSON() {
        
        let emptyJSON: Data = .emptyJSON
        
        XCTAssertNoDiff(
            map(emptyJSON),
            .failure(.invalid(statusCode: 200, data: emptyJSON))
        )
    }
    
    func test_map_shouldDeliverInvalidFailureOnEmptyDataResponse() {
        
        let emptyDataResponse: Data = .emptyDataResponse
        
        XCTAssertNoDiff(
            map(emptyDataResponse),
            .failure(.invalid(statusCode: 200, data: emptyDataResponse))
        )
    }
    
    func test_map_shouldDeliverInvalidFailureOnNullServerResponse() {
        
        let nullServerResponse: Data = .nullServerResponse
        
        XCTAssertNoDiff(
            map(.nullServerResponse),
            .failure(.invalid(statusCode: 200, data: nullServerResponse))
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
    
    func test_map_shouldDeliverInvalidFailureOnNonOkHTTPResponse() {
        
        for statusCode in [199, 201, 399, 400, 401, 404] {
            
            let nonOkResponse = anyHTTPURLResponse(statusCode: statusCode)
            
            XCTAssertNoDiff(
                map(.validData, nonOkResponse),
                .failure(.invalid(statusCode: statusCode, data: .validData))
            )
        }
    }
    
    func test_map_shouldDeliverEmptyOnEmptyList() {
        
        let emptyDataResponse: Data = .emptyListResponse
        
        XCTAssertNoDiff(
            map(emptyDataResponse),
            .success(.init(list: [], serial: "1bebd140bc2660211fbba306105479ae"))
        )
    }
    
    func test_map_shouldDeliverResponseWithOne() throws {
        
        try assert(.one, .one)
    }
    
    func test_map_shouldDeliverResponse() throws {
        
        try assert(.validData, .valid)
    }
    
    func test_live_() throws {
        
        let response = try map(String.live_20240822.json).get()
        XCTAssertEqual(response.list.count, 13)
    }
    
    // MARK: - Helpers
    
    private typealias Response = ResponseMapper.GetServiceCategoryListResponse
    private typealias MappingResult = ResponseMapper.MappingResult<Response>
    
    private func map(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse = anyHTTPURLResponse()
    ) -> MappingResult {
        
        ResponseMapper.mapGetServiceCategoryListResponse(data, httpURLResponse)
    }
    
    private func assert(
        _ data: Data,
        _ response: Response,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        let receivedResponse = try map(data).get()
        XCTAssertNoDiff(receivedResponse, response, file: file, line: line)
    }
}

private extension ResponseMapper.GetServiceCategoryListResponse {
    
    static let one: Self = .init(
        list: [
            .init(
                latestPaymentsCategory: "isMobilePayments",
                md5Hash: "c16ee4f2d0b7cea6f8b92193bccce4d7",
                name: "Мобильная связь",
                ord: 20,
                paymentFlow: .mobile,
                hasSearch: false,
                type: "mobile"
            )
        ],
        serial: "1bebd140bc2660211fbba306105479ae"
    )
    static let valid: Self = .init(
        list: [
            .init(
                latestPaymentsCategory: nil,
                md5Hash: "2d777a4bb3f53d495026b4884bbedde4",
                name: "Оплата по QR",
                ord: 10,
                paymentFlow: .qr,
                hasSearch: false,
                type: "qr"
            ),
            .init(
                latestPaymentsCategory: "isMobilePayments",
                md5Hash: "c16ee4f2d0b7cea6f8b92193bccce4d7",
                name: "Мобильная связь",
                ord: 20,
                paymentFlow: .mobile,
                hasSearch: false,
                type: "mobile"
            ),
            .init(
                latestPaymentsCategory: "isServicePayments",
                md5Hash: "ffc64acafb053c5e6ebc4e9300f7cccc",
                name: "Услуги ЖКХ",
                ord: 30,
                paymentFlow: .standard,
                hasSearch: true,
                type: "housingAndCommunalService"
            ),
            .init(
                latestPaymentsCategory: "isServicePayments",
                md5Hash: "c15643f89507e5fd4f5caef8fbd3e4df",
                name: "Интернет, ТВ",
                ord: 40,
                paymentFlow: .standard,
                hasSearch: true,
                type: "internet"
            ),
            .init(
                latestPaymentsCategory: "isTransportPayments",
                md5Hash: "23d9ad3ce923f736b8ee4c5a11cb1915",
                name: "Транспорт",
                ord: 50,
                paymentFlow: .transport,
                hasSearch: false,
                type: "transport"
            ),
            .init(
                latestPaymentsCategory: "isTaxAndStateServicePayments",
                md5Hash: "a49599eb358791b62b8d4c6341a163e5",
                name: "Налоги и госуслуги",
                ord: 60,
                paymentFlow: .taxAndStateServices,
                hasSearch: false,
                type: "taxAndStateService"
            ),
            .init(
                latestPaymentsCategory: "isSecurityPayments",
                md5Hash: "12e2479526b75f3ac2cf2b4bf420626d",
                name: "Охранные системы",
                ord: 70,
                paymentFlow: .standard,
                hasSearch: true,
                type: "security"
            ),
            .init(
                latestPaymentsCategory: "isDigitalWalletsPayments",
                md5Hash: "39e857d35b8e683526ec4912845f1c55",
                name: "Электронный кошелек",
                ord: 80,
                paymentFlow: .standard,
                hasSearch: false,
                type: "digitalWallets"
            ),
            .init(
                latestPaymentsCategory: "isRepaymentLoansAndAccountsPayments",
                md5Hash: "9f37d214d2462f2c5dc952c553613cc6",
                name: "Погашение кредита ",
                ord: 90,
                paymentFlow: .standard,
                hasSearch: true,
                type: "repaymentLoansAndAccounts"
            ),
            .init(
                latestPaymentsCategory: "isSocialAndGamesPayments",
                md5Hash: "d7d1c6adc224e96343c012ca1fcf1472",
                name: "Развлечения (игры и соц.сети)",
                ord: 100,
                paymentFlow: .standard,
                hasSearch: true,
                type: "socialAndGames"
            ),
            .init(
                latestPaymentsCategory: "isNetworkMarketingPayments",
                md5Hash: "9a2b90b30cf0e65dccb44f43d3c1e145",
                name: "Сетевой маркетинг",
                ord: 110,
                paymentFlow: .standard,
                hasSearch: true,
                type: "networkMarketing"
            ),
            .init(
                latestPaymentsCategory: "isEducationPayments",
                md5Hash: "a83b5b005fc16c356b2456d5a514c842",
                name: "Образование",
                ord: 120,
                paymentFlow: .standard,
                hasSearch: true,
                type: "education"
            ),
            .init(
                latestPaymentsCategory: "isCharityPayments",
                md5Hash: "f7463aa7646d1e2cfe33f71ab4a72d75",
                name: "Благотворительность",
                ord: 130,
                paymentFlow: .standard,
                hasSearch: true,
                type: "charity"
            ),
        ],
        serial: "1bebd140bc2660211fbba306105479ae"
    )
}

private extension Data {
    
    static let empty: Data = .init()
    static let invalidData: Data = String.invalidData.json
    static let emptyJSON: Data = String.emptyJSON.json
    static let emptyDataResponse: Data = String.emptyDataResponse.json
    static let emptyListResponse: Data = String.emptyList.json
    static let nullServerResponse: Data = String.nullServerResponse.json
    static let serverError: Data = String.serverError.json
    static let one: Data = String.one.json
    static let validData: Data = String.validData.json
}

private extension String {
    
    static let mobile = "MOBILE"
    static let qr = "QR"
    static let standard = "STANDARD_FLOW"
    static let taxAndStateServices = "TAX_AND_STATE_SERVICE"
    static let transport = "TRANSPORT"
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
  "data": {
    "serial": "1bebd140bc2660211fbba306105479ae",
    "categoryGroupList": []
  }
}
"""
    
    static let one = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "serial": "1bebd140bc2660211fbba306105479ae",
    "categoryGroupList": [
      {
        "type": "mobile",
        "name": "Мобильная связь",
        "ord": 20,
        "md5hash": "c16ee4f2d0b7cea6f8b92193bccce4d7",
        "paymentFlow": "MOBILE",
        "latestPaymentsCategory": "isMobilePayments",
        "search": false
      }
    ]
  }
}
"""
    
    static let validData = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "serial": "1bebd140bc2660211fbba306105479ae",
    "categoryGroupList": [
      {
        "type": "qr",
        "name": "Оплата по QR",
        "ord": 10,
        "md5hash": "2d777a4bb3f53d495026b4884bbedde4",
        "paymentFlow": "QR",
        "latestPaymentsCategory": null,
        "search": false
      },
      {
        "type": "mobile",
        "name": "Мобильная связь",
        "ord": 20,
        "md5hash": "c16ee4f2d0b7cea6f8b92193bccce4d7",
        "paymentFlow": "MOBILE",
        "latestPaymentsCategory": "isMobilePayments",
        "search": false
      },
      {
        "type": "housingAndCommunalService",
        "name": "Услуги ЖКХ",
        "ord": 30,
        "md5hash": "ffc64acafb053c5e6ebc4e9300f7cccc",
        "paymentFlow": "STANDARD_FLOW",
        "latestPaymentsCategory": "isServicePayments",
        "search": true
      },
      {
        "type": "internet",
        "name": "Интернет, ТВ",
        "ord": 40,
        "md5hash": "c15643f89507e5fd4f5caef8fbd3e4df",
        "paymentFlow": "STANDARD_FLOW",
        "latestPaymentsCategory": "isServicePayments",
        "search": true
      },
      {
        "type": "transport",
        "name": "Транспорт",
        "ord": 50,
        "md5hash": "23d9ad3ce923f736b8ee4c5a11cb1915",
        "paymentFlow": "TRANSPORT",
        "latestPaymentsCategory": "isTransportPayments",
        "search": false
      },
      {
        "type": "taxAndStateService",
        "name": "Налоги и госуслуги",
        "ord": 60,
        "md5hash": "a49599eb358791b62b8d4c6341a163e5",
        "paymentFlow": "TAX_AND_STATE_SERVICE",
        "latestPaymentsCategory": "isTaxAndStateServicePayments",
        "search": false
      },
      {
        "type": "security",
        "name": "Охранные системы",
        "ord": 70,
        "md5hash": "12e2479526b75f3ac2cf2b4bf420626d",
        "paymentFlow": "STANDARD_FLOW",
        "latestPaymentsCategory": "isSecurityPayments",
        "search": true
      },
      {
        "type": "digitalWallets",
        "name": "Электронный кошелек",
        "ord": 80,
        "md5hash": "39e857d35b8e683526ec4912845f1c55",
        "paymentFlow": "STANDARD_FLOW",
        "latestPaymentsCategory": "isDigitalWalletsPayments",
        "search": false
      },
      {
        "type": "repaymentLoansAndAccounts",
        "name": "Погашение кредита ",
        "ord": 90,
        "md5hash": "9f37d214d2462f2c5dc952c553613cc6",
        "paymentFlow": "STANDARD_FLOW",
        "latestPaymentsCategory": "isRepaymentLoansAndAccountsPayments",
        "search": true
      },
      {
        "type": "socialAndGames",
        "name": "Развлечения (игры и соц.сети)",
        "ord": 100,
        "md5hash": "d7d1c6adc224e96343c012ca1fcf1472",
        "paymentFlow": "STANDARD_FLOW",
        "latestPaymentsCategory": "isSocialAndGamesPayments",
        "search": true
      },
      {
        "type": "networkMarketing",
        "name": "Сетевой маркетинг",
        "ord": 110,
        "md5hash": "9a2b90b30cf0e65dccb44f43d3c1e145",
        "paymentFlow": "STANDARD_FLOW",
        "latestPaymentsCategory": "isNetworkMarketingPayments",
        "search": true
      },
      {
        "type": "education",
        "name": "Образование",
        "ord": 120,
        "md5hash": "a83b5b005fc16c356b2456d5a514c842",
        "paymentFlow": "STANDARD_FLOW",
        "latestPaymentsCategory": "isEducationPayments",
        "search": true
      },
      {
        "type": "charity",
        "name": "Благотворительность",
        "ord": 130,
        "md5hash": "f7463aa7646d1e2cfe33f71ab4a72d75",
        "paymentFlow": "STANDARD_FLOW",
        "latestPaymentsCategory": "isCharityPayments",
        "search": true
      }
    ]
  }
}
"""
    
    static let live_20240822 = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "serial": "84bf007c17787f15f95b7cddafd8f340",
    "categoryGroupList": [
      {
        "type": "qr",
        "name": "Оплата по QR",
        "ord": 10,
        "md5hash": "2d777a4bb3f53d495026b4884bbedde4",
        "paymentFlow": "QR",
        "latestPaymentsCategory": null,
        "search": false
      },
      {
        "type": "mobile",
        "name": "Мобильная связь",
        "ord": 20,
        "md5hash": "c16ee4f2d0b7cea6f8b92193bccce4d7",
        "paymentFlow": "MOBILE",
        "latestPaymentsCategory": "isMobilePayments",
        "search": false
      },
      {
        "type": "housingAndCommunalService",
        "name": "Услуги ЖКХ",
        "ord": 30,
        "md5hash": "ffc64acafb053c5e6ebc4e9300f7cccc",
        "paymentFlow": "STANDARD_FLOW",
        "latestPaymentsCategory": "isServicePayments",
        "search": true
      },
      {
        "type": "internet",
        "name": "Интернет, ТВ",
        "ord": 40,
        "md5hash": "c15643f89507e5fd4f5caef8fbd3e4df",
        "paymentFlow": "STANDARD_FLOW",
        "latestPaymentsCategory": "isInternetPayments",
        "search": true
      },
      {
        "type": "transport",
        "name": "Транспорт",
        "ord": 50,
        "md5hash": "23d9ad3ce923f736b8ee4c5a11cb1915",
        "paymentFlow": "TRANSPORT",
        "latestPaymentsCategory": "isTransportPayments",
        "search": false
      },
      {
        "type": "taxAndStateService",
        "name": "Налоги и госуслуги",
        "ord": 60,
        "md5hash": "a49599eb358791b62b8d4c6341a163e5",
        "paymentFlow": "TAX_AND_STATE_SERVICE",
        "latestPaymentsCategory": "isTaxAndStateServicePayments",
        "search": false
      },
      {
        "type": "security",
        "name": "Охранные системы",
        "ord": 70,
        "md5hash": "12e2479526b75f3ac2cf2b4bf420626d",
        "paymentFlow": "STANDARD_FLOW",
        "latestPaymentsCategory": "isSecurityPayments",
        "search": true
      },
      {
        "type": "digitalWallets",
        "name": "Электронный кошелек",
        "ord": 80,
        "md5hash": "39e857d35b8e683526ec4912845f1c55",
        "paymentFlow": "STANDARD_FLOW",
        "latestPaymentsCategory": "isDigitalWalletsPayments",
        "search": false
      },
      {
        "type": "repaymentLoansAndAccounts",
        "name": "Погашение кредита",
        "ord": 90,
        "md5hash": "9f37d214d2462f2c5dc952c553613cc6",
        "paymentFlow": "STANDARD_FLOW",
        "latestPaymentsCategory": "isRepaymentLoansAndAccountsPayments",
        "search": true
      },
      {
        "type": "socialAndGames",
        "name": "Развлечения (игры и соц.сети)",
        "ord": 100,
        "md5hash": "d7d1c6adc224e96343c012ca1fcf1472",
        "paymentFlow": "STANDARD_FLOW",
        "latestPaymentsCategory": "isSocialAndGamesPayments",
        "search": true
      },
      {
        "type": "networkMarketing",
        "name": "Сетевой маркетинг",
        "ord": 110,
        "md5hash": "9a2b90b30cf0e65dccb44f43d3c1e145",
        "paymentFlow": "STANDARD_FLOW",
        "latestPaymentsCategory": "isNetworkMarketingPayments",
        "search": true
      },
      {
        "type": "education",
        "name": "Образование",
        "ord": 120,
        "md5hash": "a83b5b005fc16c356b2456d5a514c842",
        "paymentFlow": "STANDARD_FLOW",
        "latestPaymentsCategory": "isEducationPayments",
        "search": true
      },
      {
        "type": "charity",
        "name": "Благотворительность",
        "ord": 130,
        "md5hash": "f7463aa7646d1e2cfe33f71ab4a72d75",
        "paymentFlow": "STANDARD_FLOW",
        "latestPaymentsCategory": "isCharityPayments",
        "search": true
      }
    ]
  }
}
"""
}
