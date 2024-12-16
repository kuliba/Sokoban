//
//  ResponseMapper+mapGetBankDefaultResponseTests.swift
//
//
//  Created by Igor Malyarov on 28.12.2023.
//

import FastPaymentsSettings
import RemoteServices
import XCTest

final class ResponseMapper_mapGetBankDefaultResponseTests: XCTestCase {
    
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

    func test_map_shouldDeliverResponseOnOkHTTPURLResponseStatusCodeWithValidData_c1() throws {
        
        let validData = Data(jsonString_c1.utf8)
        let result = map(validData)
        
        assert(result, equals: .success(.c1))
    }
    
    func test_map_shouldDeliverResponseOnOkHTTPURLResponseStatusCodeWithValidData_c2() throws {
        
        let validData = Data(jsonString_c2.utf8)
        let result = map(validData)
        
        assert(result, equals: .success(.c2))
    }
    
    #warning("move to client test")
//    func test_map_shouldDeliverLimitErrorOnSpecificMessage_c3() throws {
//        
//        let specificMessageData = Data(jsonString_c3.utf8)
//        let result = map(specificMessageData)
//        
//        assert(result, equals: .failure(.limit(errorMessage: limitErrorMessage)))
//    }
    
    // MARK: - Helpers
    
    private func map(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse = anyHTTPURLResponse()
    ) -> ResponseMapper.MappingResult<BankDefault> {
        
        ResponseMapper.mapGetBankDefaultResponse(data, httpURLResponse)
    }
    
    private let limitErrorMessage = "Исчерпан лимит запросов. Повторите попытку через 24 часа."
}

private extension BankDefault {
    
    static let c1: Self = true
    static let c2: Self = false
}

private let jsonString_c1 = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "foraBank": true
  }
}
"""

private let jsonString_c2 = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "foraBank": false
  }
}
"""

private let jsonString_c3 = """
{
    "statusCode": 102,
    "errorMessage": "Исчерпан лимит запросов. Повторите попытку через 24 часа.",
    "data": null
}
"""
