//
//  ResponseMapper+mapGetPaymentTemplateListResponseTests.swift
//
//
//  Created by Igor Malyarov on 13.08.2024.
//

import PaymentTemplateBackendV3
import RemoteServices
import XCTest

final class ResponseMapper_mapGetPaymentTemplateListResponseTests: XCTestCase {
    
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
    
    func test_map_shouldDeliverInvalidFailureOnNonOkHTTPResponse() throws {
        
        for statusCode in [199, 201, 399, 400, 401, 404] {
            
            let data = try data(from: "v3_getPaymentTemplateList")
            let nonOkResponse = anyHTTPURLResponse(statusCode: statusCode)
            
            XCTAssertNoDiff(
                map(data, nonOkResponse),
                .failure(.invalid(statusCode: statusCode, data: data))
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
    
    func test_fileData() throws {
        
        let mapped = try map(data(from: "v3_getPaymentTemplateList")).get()
                
        XCTAssertEqual(mapped.templates.count, 47)
    }
    
    func test_fileData_housing() throws {
        
        try assert(data(from: "v3_getPaymentTemplateList_housing"), .init(
            serial: "19975e6eb7a590251afdd00e6fdbc7fa",
            templates: [
                makeTemplate(
                    id: 5920,
                    group: "Услуги ЖКХ",
                    inn: "7606052264",
                    name: "ПАО ТНС энерго Ярославль",
                    parameters: [
                        makeParameter(
                            amount: 12.7,
                            payer: makePayer(
                                cardID: 10000216938
                            )
                        )
                    ],
                    paymentFlow: .standard,
                    sort: 23,
                    type: .housingAndCommunalService
                )
            ]
        ))
    }
    
    func test_fileData_newFields() throws {
        
        try assert(data(from: "v3_getPaymentTemplateList_newFields"), .init(
            serial: "19975e6eb7a590251afdd00e6fdbc7fa",
            templates: [
                makeTemplate(
                    id: 6199,
                    group: "Транспорт",
                    inn: "7710965662",
                    md5Hash: "425e86123a5415c2ada1770b9e4abf1b",
                    name: "Автодор Платные дороги (по договору)",
                    parameters: [
                        makeParameter(
                            amount: 10,
                            payer: makePayer(
                                cardID: 10000220675
                            )
                        )
                    ],
                    paymentFlow: .transport,
                    sort: 48,
                    type: .transport
                )
            ]
        ))
    }
    
    func test_fileData_one() throws {
        
        try assert(data(from: "v3_getPaymentTemplateList_one"), .init(
            serial: "19975e6eb7a590251afdd00e6fdbc7fa",
            templates: [
                makeTemplate(
                    id: 3760,
                    group: "Перевод МИГ",
                    md5Hash: "2dab5e994b3925a213dd63bffcc948ab",
                    name: "Э. Финстрим Финстримович",
                    parameters: [
                        makeParameter(
                            payer: makePayer(
                                cardID: 10000216938
                            )
                        ),
                        makeParameter(
                            payer: makePayer(
                                cardID: 10000216938
                            )
                        ),
                        makeParameter(
                            amount: 120,
                            payer: makePayer(
                                cardID: 10000216938
                            )
                        ),
                    ],
                    sort: 1,
                    type: .newDirect
                ),
            ]
        ))
    }
    
    // MARK: - Helpers
    
    private typealias Response = ResponseMapper.GetPaymentTemplateListResponse
    private typealias MappingResult = ResponseMapper.MappingResult<Response>
    
    private func map(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse = anyHTTPURLResponse()
    ) -> MappingResult {
        
        ResponseMapper.mapGetPaymentTemplateListResponse(data, httpURLResponse)
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
    
    private func data(
        from filename: String,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> Data {
        
        let filename = Bundle.module.url(forResource: filename, withExtension: "json")
        let url = try XCTUnwrap(filename, file: file, line: line)
        return try Data(contentsOf: url)
    }
    
    private func makeTemplate(
        id: Int,
        group: String,
        inn: String? = nil,
        md5Hash: String? = nil,
        name: String,
        parameters: [ResponseMapper.GetPaymentTemplateListResponse.Template.Parameter],
        paymentFlow: ResponseMapper.GetPaymentTemplateListResponse.Template.PaymentFlow? = nil,
        sort: Int,
        type: ResponseMapper.GetPaymentTemplateListResponse.Template.TemplateType
    ) -> ResponseMapper.GetPaymentTemplateListResponse.Template {
        
        return .init(
            id: id,
            group: group,
            inn: inn,
            md5Hash: md5Hash,
            name: name,
            parameters: parameters,
            paymentFlow: paymentFlow,
            sort: sort,
            type: type
        )
    }
    
    private func makeParameter(
        amount: Decimal? = nil,
        check: Bool? = false,
        currency: String? = "RUB",
        payer: ResponseMapper.GetPaymentTemplateListResponse.Template.Parameter.Payer? = nil,
        comment: String? = nil
    ) -> ResponseMapper.GetPaymentTemplateListResponse.Template.Parameter {
        
        return .init(
            amount: amount,
            check: check,
            currency: currency,
            payer: payer,
            comment: comment
        )
    }
    
    private func makePayer(
        cardID: Int? = nil,
        cardNumber: String? = nil,
        accountID: Int? = nil,
        accountNumber: String? = nil,
        phoneNumber: String? = nil,
        inn: String? = nil
    ) -> ResponseMapper.GetPaymentTemplateListResponse.Template.Parameter.Payer {
        
        return .init(
            cardID: cardID,
            cardNumber: cardNumber,
            accountID: accountID,
            accountNumber: accountNumber,
            phoneNumber: phoneNumber,
            inn: inn
        )
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
    "templateList": []
  }
}
"""
}
