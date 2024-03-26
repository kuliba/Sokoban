//
//  ResponseMapper+mapCreateAnywayTransferResponseTests.swift
//
//
//  Created by Igor Malyarov on 25.03.2024.
//

import AnywayPayment
import RemoteServices
import XCTest

final class ResponseMapper_mapCreateAnywayTransferResponseTests: XCTestCase {
    
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
    
    func test_map_shouldDeliverResponse() throws {
        
        try assert(.validData, .init(
            additionals: [],
            finalStep: false,
            needMake: false,
            needOTP: false,
            needSum: false,
            parametersForNextStep: [
                .init(
                    dataType: "%String",
                    id: "1",
                    inputFieldType: .account,
                    isPrint: true,
                    isRequired: true,
                    order: 1,
                    phoneBook: false,
                    rawLength: 0,
                    isReadOnly: false,
                    regExp: "^.{1,250}$",
                    svgImage: "svgImage",
                    title: "Лицевой счет",
                    type: "Input",
                    viewType: .input
                )
            ],
            paymentOperationDetailID: 54321
        ))
    }
    
    // MARK: - Helpers
    
    private typealias Response = ResponseMapper.CreateAnywayTransferResponse
    private typealias MappingResult = ResponseMapper.MappingResult<Response>
    
    private func map(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse = anyHTTPURLResponse()
    ) -> MappingResult {
        
        ResponseMapper.mapCreateAnywayTransferResponse(data, httpURLResponse)
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
        "needMake": null,
        "needOTP": null,
        "amount": null,
        "creditAmount": null,
        "fee": null,
        "currencyAmount": null,
        "currencyPayer": null,
        "currencyPayee": null,
        "currencyRate": null,
        "debitAmount": null,
        "payeeName": null,
        "paymentOperationDetailId": 54321,
        "documentStatus": null,
        "needSum": false,
        "additionalList": [],
        "parameterListForNextStep": [
            {
                "id": "1",
                "order": 1,
                "title": "Лицевой счет",
                "subTitle": null,
                "viewType": "INPUT",
                "dataType": "%String",
                "type": "Input",
                "mask": null,
                "regExp": "^.{1,250}$",
                "maxLength": null,
                "minLength": null,
                "rawLength": 0,
                "isRequired": true,
                "content": null,
                "readOnly": false,
                "isPrint": true,
                "svgImage": "svgImage",
                "inputFieldType": "ACCOUNT",
                "dataDictionary": null,
                "dataDictionaryРarent": null,
                "group": null,
                "subGroup": null,
                "inputMask": null,
                "phoneBook": null
            }
        ],
        "finalStep": false,
        "infoMessage": null,
        "printFormType": null,
        "scenario": null
    }
}
"""
}
