//
//  ResponseMapper+mapGetInfoRepeatPaymentResponseTests.swift
//
//
//  Created by Andryusina Nataly on 20.12.2024.
//

import GetInfoRepeatPaymentService
import RemoteServices
import XCTest

final class ResponseMapper_mapGetInfoRepeatPaymentResponseTests: XCTestCase {
    
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
    
    func test_map_shouldDeliverInvalidFailureOnNonOkHTTPResponse() {
        
        for statusCode in [199, 201, 399, 400, 401, 404] {
            
            let nonOkResponse = anyHTTPURLResponse(with: statusCode)
            
            XCTAssertNoDiff(
                map(.validData, nonOkResponse),
                .failure(.invalid(statusCode: statusCode, data: .validData))
            )
        }
    }
    
    func test_map_shouldDeliverResponseWithValidData() throws {
        
        try assert(.validData, .validData)
    }
    
    func test_map_shouldDeliverInvalidFailureWithTypeNull() {
        
        XCTAssertNoDiff(
            map(.typeNullData),
            .failure(.invalid(statusCode: 200, data: .typeNullData))
        )
    }
    
    // MARK: - Helpers
    
    private typealias Response = ResponseMapper.GetInfoRepeatPaymentResult
    private typealias MappingResult = ResponseMapper.MappingResult<Response>
    
    private func map(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse = anyHTTPURLResponse()
    ) -> MappingResult {
        
        ResponseMapper.mapGetInfoRepeatPaymentResponse(data, httpURLResponse)
    }
    
    private func mapResult(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse = anyHTTPURLResponse()
    ) throws -> Response {
        
        try ResponseMapper.mapGetInfoRepeatPaymentResponse(data, httpURLResponse).get()
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
    static let typeNullData: Data = String.typeNullData.json
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
        "type": "BETWEEN_THEIR",
        "parameterList": [
          {
            "check": true,
            "amount": 23,
            "currencyAmount": "RUB",
            "payer": {
              "cardId": 10000249264,
              "cardNumber": null,
              "accountId": null,
              "accountNumber": null,
              "phoneNumber": null,
              "INN": null
            },
            "comment": null,
            "payeeInternal": {
              "cardId": null,
              "cardNumber": null,
              "accountId": 10004874290,
              "accountNumber": null,
              "phoneNumber": null,
              "productCustomName": null
            },
            "payeeExternal": null
          }
        ]
      }
    }
"""
    
    static let typeNullData = """
    {
      "statusCode": 0,
      "errorMessage": null,
      "data": {
        "type": null,
        "parameterList": [
          {
            "check": true,
            "amount": 23,
            "currencyAmount": "RUB",
            "payer": {
              "cardId": 10000249264,
              "cardNumber": null,
              "accountId": null,
              "accountNumber": null,
              "phoneNumber": null,
              "INN": null
            },
            "comment": null,
            "payeeInternal": {
              "cardId": null,
              "cardNumber": null,
              "accountId": 10004874290,
              "accountNumber": null,
              "phoneNumber": null,
              "productCustomName": null
            },
            "payeeExternal": null
          }
        ]
      }
    }
"""
}

private extension GetInfoRepeatPaymentDomain.GetInfoRepeatPayment {
    
    static let validData: Self = .init(
        type: "BETWEEN_THEIR",
        parameterList: [
            .init(check: true, amount: 23, currencyAmount: "RUB", payer: .init(cardId: 10000249264, cardNumber: nil, accountId: nil, accountNumber: nil, phoneNumber: nil, inn: nil), comment: nil, puref: nil, payeeInternal: .init(accountId: 10004874290, accountNumber: nil, cardId: nil, cardNumber: nil, phoneNumber: nil, productCustomName: nil), payeeExternal: nil, additional: nil, mcc: nil)
        ],
        productTemplate: nil,
        paymentFlow: nil)
}
