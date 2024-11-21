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
    
    func test_map_onlyAccountBannerList_shouldDeliverValidData() {
        
        let (json, response) = createAccountBannerList()
        
        XCTAssertNoDiff(
            map(Data(json.utf8)),
            .success(response)
        )
    }

    func test_map_onlyLoanBannerList_shouldDeliverValidData() {
        
        let (json, response) = createLoanBannerList()
        
        XCTAssertNoDiff(
            map(Data(json.utf8)),
            .success(response)
        )
    }
    
    func test_map_onlyCardBannerList_shouldDeliverValidData() {
        
        let (json, response) = createCardBannerList()
        
        XCTAssertNoDiff(
            map(Data(json.utf8)),
            .success(response)
        )
    }
    
    func test_map_allBannerList_shouldDeliverValidData() {
        
        let (json, response) = createBannerList()
        
        XCTAssertNoDiff(
            map(Data(json.utf8)),
            .success(response)
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
    
    typealias List = ResponseMapper.GetBannersMyProductListResponse
    typealias Banner = List.Banner
    typealias Response = ResponseMapper.MappingResult<List>
    
    private func map(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse = anyHTTPURLResponse()
    ) -> Response {
        ResponseMapper.mapGetBannersMyProductListResponse(data, httpURLResponse)
    }
    
    private func createAccountBannerList(
        serial: String = anySerial(),
        productName: String = anyMessage(),
        link: String = anyMessage(),
        md5hash: String = anyMessage(),
        actionType: String = anyMessage(),
        target: String = anyMessage()
    ) -> (String, List) {
        
        let banner = "[" + createBanner(productName: productName, link: link, md5hash: md5hash, actionType: actionType, target: target) + "]"
        
        return (
            json(serial: serial, accountBannerList: banner),
            .init(
                serial: serial,
                accountBannerList: [.init(
                    productName: productName,
                    link: link,
                    md5hash: md5hash,
                    action: .init(actionType: actionType, target: target))],
                cardBannerList: [],
                loanBannerList: [])
        )
    }

    private func createLoanBannerList(
        serial: String = anySerial(),
        productName: String = anyMessage(),
        link: String = anyMessage(),
        md5hash: String = anyMessage(),
        actionType: String = anyMessage(),
        target: String = anyMessage()
    ) -> (String, List) {
        
        let banner = "[" + createBanner(productName: productName, link: link, md5hash: md5hash, actionType: actionType, target: target) + "]"
        
        return (
            json(serial: serial, loanBannerList: banner),
            .init(
                serial: serial,
                accountBannerList: [],
                cardBannerList: [],
                loanBannerList: [
                    .init(
                        productName: productName,
                        link: link,
                        md5hash: md5hash,
                        action: .init(actionType: actionType, target: target))])
        )
    }
    
    private func createCardBannerList(
        serial: String = anySerial(),
        productName: String = anyMessage(),
        link: String = anyMessage(),
        md5hash: String = anyMessage(),
        actionType: String = anyMessage(),
        target: String = anyMessage()
    ) -> (String, List) {
        
        let banner = "[" + createBanner(productName: productName, link: link, md5hash: md5hash, actionType: actionType, target: target) + "]"
        
        return (
            json(serial: serial, cardBannerList: banner),
            .init(
                serial: serial,
                accountBannerList: [],
                cardBannerList: [.init(
                    productName: productName,
                    link: link,
                    md5hash: md5hash,
                    action: .init(actionType: actionType, target: target))],
                loanBannerList: [])
        )
    }
    
    private func createBannerList(
        serial: String = anySerial(),
        productName: String = anyMessage(),
        link: String = anyMessage(),
        md5hash: String = anyMessage(),
        actionType: String = anyMessage(),
        target: String = anyMessage()
    ) -> (String, List) {
        
        let banner = "[" + createBanner(productName: productName, link: link, md5hash: md5hash, actionType: actionType, target: target) + "]"
        
        return (
            json(serial: serial, accountBannerList: banner, cardBannerList: banner, loanBannerList: banner),
            .init(
                serial: serial,
                accountBannerList: [.init(
                    productName: productName,
                    link: link,
                    md5hash: md5hash,
                    action: .init(actionType: actionType, target: target))],
                cardBannerList: [.init(
                    productName: productName,
                    link: link,
                    md5hash: md5hash,
                    action: .init(actionType: actionType, target: target))],
                loanBannerList: [.init(
                    productName: productName,
                    link: link,
                    md5hash: md5hash,
                    action: .init(actionType: actionType, target: target))])
        )
    }
    
    private func createBanner(
        productName: String,
        link: String,
        md5hash: String,
        actionType: String,
        target: String
    ) -> String {
        """
        {
            "productName": "\(productName)",
            "link": "\(link)",
            "md5hash": "\(md5hash)",
            "action": {
                "actionType": "\(actionType)",
                "target": "\(target)"
            }
        },
    """
    }
    
    private func json(
        serial: String,
        accountBannerList: String = "null",
        cardBannerList: String = "null",
        loanBannerList: String = "null"
    ) -> String {
            """
        {
            "statusCode": 0,
            "errorMessage": null,
            "data": {
                "serial": "\(serial)",
                "accountBannerList": \(accountBannerList),
                "cardBannerList": \(cardBannerList),
                "loanBannerList": \(loanBannerList)
            }
        }
        """
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
        "accountBannerList": [{
            "productName": "Накопительный счет",
            "link": "https://www.forabank.ru/private/",
            "md5hash": "",
            "action": {
                "target": "DEFAULT",
                "actionType": "SAVING_LANDING"
            }
        }],
        "cardBannerList": [{
            "productName": "Платежный стикер",
            "link": "",
            "md5hash": "baf4ce68d067b657e21ce34f2d6a92c9",
            "action": {
                "actionType": "landing",
                "target": "landingSticker"
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
}
