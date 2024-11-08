//
//  ResponseMapper+mapGetBannersMyProductListResponseTests.swift
//
//
//  Created by Valentin Ozerov on 23.10.2024.
//

import RemoteServices
import XCTest
import GetBannersMyProductListService

final class ResponseMapper_mapGetBannersMyProductListResponseTests: XCTestCase {
    
    func test_map_shouldDeliverValidData() {
        
        XCTAssertNoDiff(
            map(.validData),
            .success(.validStub)
        )
    }

    func test_map_shouldDeliverWithOnlyCardBanners() {
        
        XCTAssertNoDiff(
            map(.onlyCardBannersData),
            .success(.stubWithOnlyCardBanners)
        )
    }

    func test_map_shouldDeliverWithOnlyLoanBanners() {
        
        XCTAssertNoDiff(
            map(.onlyLoanBannersData),
            .success(.stubWithOnlyLoanBanners)
        )
    }

    func test_map_shouldDeliverWithoutBanners() {
        
        XCTAssertNoDiff(
            map(.withoutBannersData),
            .success(.stubWithoutBanners)
        )
    }

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
    
    private typealias Response = [ResponseMapper.CreateGetBannersMyProductListApplicationDomain]
    private typealias MappingResult = Swift.Result<
        ResponseMapper.CreateGetBannersMyProductListApplicationDomain,
        ResponseMapper.MappingError
    >
    
    private func map(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse = anyHTTPURLResponse()
    ) -> MappingResult {
        ResponseMapper.mapGetBannersMyProductListResponse(data, httpURLResponse)
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
    static let onlyCardBannersData: Data = String.jsonWithOnlyCardBanners.json
    static let onlyLoanBannersData: Data = String.jsonWithOnlyLoanBanners.json
    static let withoutBannersData: Data = String.jsonWithoutBanners.json
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
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "serial": "7134778f549cab1edc68704066472e72",
        "cardBannerList": [{
            "productName": "Платежный стикер",
            "link": "",
            "md5hash": "baf4ce68d067b657e21ce34f2d6a92c9",
            "action": {
                "actionType": "landing",
                "landingData": "landingSticker"
            }
        }],
        "loanBannerList": [{
            "productName": "Кредит под залог транспорта",
            "link": "https://www.forabank.ru/private/credits/zalogovyy/",
            "md5hash": "0f2c00910196b526db03abd7ee2af4a1",
            "action": {
                "actionType": "landing",
                "target": "COLLATERAL_LOAN_CALC_CAR"
            }
        }, {
            "productName": "Кредит под залог транспорта",
            "link": "https://www.forabank.ru/private/credits/zalogovyy/",
            "md5hash": "0f2c00910196b526db03abd7ee2af4a1",
            "action": {
                "actionType": "landing",
                "target": "COLLATERAL_LOAN_CALC_REAL_ESTATE"
            }
        }]
    }
}
"""
    
    static let jsonWithOnlyCardBanners = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "serial": "7134778f549cab1edc68704066472e72",
        "cardBannerList": [{
            "productName": "Платежный стикер",
            "link": "",
            "md5hash": "baf4ce68d067b657e21ce34f2d6a92c9",
            "action": {
                "actionType": "landing",
                "landingData": "landingSticker"
            }
        }],
    }
}
"""
    
    static let jsonWithOnlyLoanBanners = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "serial": "7134778f549cab1edc68704066472e72",
        "loanBannerList": [{
            "productName": "Кредит под залог транспорта",
            "link": "https://www.forabank.ru/private/credits/zalogovyy/",
            "md5hash": "0f2c00910196b526db03abd7ee2af4a1",
            "action": {
                "actionType": "landing",
                "target": "COLLATERAL_LOAN_CALC_CAR"
            }
        }, {
            "productName": "Кредит под залог транспорта",
            "link": "https://www.forabank.ru/private/credits/zalogovyy/",
            "md5hash": "0f2c00910196b526db03abd7ee2af4a1",
            "action": {
                "actionType": "landing",
                "target": "COLLATERAL_LOAN_CALC_REAL_ESTATE"
            }
        }]
    }
}
"""
    
    static let jsonWithoutBanners = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "serial": "7134778f549cab1edc68704066472e72",
    }
}
"""
}

private extension ResponseMapper.CreateGetBannersMyProductListApplicationDomain {
    
    static let validStub = makeStub(
        cardBanner: [
            Banner(
                productName: "Платежный стикер",
                link: "",
                md5hash: "baf4ce68d067b657e21ce34f2d6a92c9",
                action: .init(
                    actionType: .landing,
                    landingData: "landingSticker",
                    target: nil
                )
            )
        ],
        loanBanner: [
            Banner(
                productName: "Кредит под залог транспорта",
                link: "https://www.forabank.ru/private/credits/zalogovyy/",
                md5hash: "0f2c00910196b526db03abd7ee2af4a1",
                action: .init(
                    actionType: .landing,
                    landingData: nil,
                    target: "COLLATERAL_LOAN_CALC_CAR"
                )
            ),
            Banner(
                productName: "Кредит под залог транспорта",
                link: "https://www.forabank.ru/private/credits/zalogovyy/",
                md5hash: "0f2c00910196b526db03abd7ee2af4a1",
                action: .init(
                    actionType: .landing,
                    landingData: nil,
                    target: "COLLATERAL_LOAN_CALC_REAL_ESTATE"
                )
            )
        ]
    )
    
    static let stubWithOnlyCardBanners = makeStub(
        cardBanner: [
            Banner(
                productName: "Платежный стикер",
                link: "",
                md5hash: "baf4ce68d067b657e21ce34f2d6a92c9",
                action: .init(
                    actionType: .landing,
                    landingData: "landingSticker",
                    target: nil
                )
            )
        ],
        loanBanner: nil
    )
    
    static let stubWithOnlyLoanBanners = makeStub(
        cardBanner: nil,
        loanBanner: [
            Banner(
                productName: "Кредит под залог транспорта",
                link: "https://www.forabank.ru/private/credits/zalogovyy/",
                md5hash: "0f2c00910196b526db03abd7ee2af4a1",
                action: .init(
                    actionType: .landing,
                    landingData: nil,
                    target: "COLLATERAL_LOAN_CALC_CAR"
                )
            ),
            Banner(
                productName: "Кредит под залог транспорта",
                link: "https://www.forabank.ru/private/credits/zalogovyy/",
                md5hash: "0f2c00910196b526db03abd7ee2af4a1",
                action: .init(
                    actionType: .landing,
                    landingData: nil,
                    target: "COLLATERAL_LOAN_CALC_REAL_ESTATE"
                )
            )
        ]
    )
    
    static let stubWithoutBanners = makeStub(
        cardBanner: nil,
        loanBanner: nil
    )
}

extension ResponseMapper.CreateGetBannersMyProductListApplicationDomain {
    
    static func makeStub(cardBanner: [Banner]?, loanBanner: [Banner]?) -> Self {
        
        var cardBannerList: [Banner] = []
        var loanBannerList: [Banner] = []
        
        if let cardBanner {
            cardBannerList = cardBanner
        }

        if let loanBanner {
            loanBannerList = loanBanner
        }

        return Self(cardBannerList: cardBannerList, loanBannerList: loanBannerList)
    }
    
    typealias Banner = ResponseMapper.CreateGetBannersMyProductListApplicationDomain.Banner
}

extension ResponseMapper.CreateGetBannersMyProductListApplicationDomain.Banner {

    static func makeStub(
        productName: String = anyMessage(),
        link: String = anyMessage(),
        md5hash: String = anyMessage(),
        actionType: Banner.Action.ActionType = .allCases.randomElement() ?? .unknown,
        landingData: String? = anyMessage(),
        target: String? = anyMessage()
    ) -> Self {

        var action: Action?
        
        action = .makeStub(
            actionType: actionType,
            landingData: landingData,
            target: target
        )
        
        return Self(
            productName: productName,
            link: link,
            md5hash: md5hash,
            action: action
        )
    }
    
    typealias Banner = ResponseMapper.CreateGetBannersMyProductListApplicationDomain.Banner
}

extension ResponseMapper.CreateGetBannersMyProductListApplicationDomain.Banner.Action {

    static func makeStub(
        actionType: Response.Banner.Action.ActionType,
        landingData: String?,
        target: String?
    ) -> Self {

        Self(
            actionType: actionType,
            landingData: landingData,
            target: target
        )
    }
    
    typealias Response = ResponseMapper.CreateGetBannersMyProductListApplicationDomain
}

extension ResponseMapper.CreateGetBannersMyProductListApplicationDomain.Banner.Action.ActionType {
    
    static var allCases: [RemoteServices.ResponseMapper.CreateGetBannersMyProductListApplicationDomain.Banner.Action.ActionType] =
    [
        .depositList,
        .migTransfer,
        .migAuthTransfer,
        .contact,
        .depositTransfer,
        .landing,
        .unknown
    ]
}
