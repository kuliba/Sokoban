//
//  ResponseMapper+mapMakeSetBankDefaultResponseTests.swift
//
//
//  Created by Igor Malyarov on 28.12.2023.
//

import FastPaymentsSettings
import RemoteServices
import XCTest

final class ResponseMapper_mapMakeSetBankDefaultResponseTests: XCTestCase {
    
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
    
    func test_map_shouldDeliverVoidOnOkHTTPURLResponseStatusCodeWithValidData_g1() throws {
        
        let validData = Data(jsonString_g1.utf8)
        let result = map(validData)
        
        assert(result, equals: .success(()))
    }
    #warning("move to client tests")
//    func test_map_shouldDeliverRetryErrorOnSpecificMessage_g3() throws {
//        
//        let SpecificMessageData = Data(jsonString_g2.utf8)
//        let result = map(SpecificMessageData)
//        
//        assert(result, equals: .failure(.retry(errorMessage: retryErrorMessage)))
//    }
    
    // MARK: - Helpers
    
    private func map(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse = anyHTTPURLResponse()
    ) -> ResponseMapper.VoidMappingResult {
        
        ResponseMapper.mapMakeSetBankDefaultResponse(data, httpURLResponse)
    }
    
    private let retryErrorMessage = "Введен некорректный код. Попробуйте еще раз."
}

private let jsonString_g1 = nullServerResponse

private let jsonString_g2 = """
{
  "statusCode": 102,
  "errorMessage": "Введен некорректный код. Попробуйте еще раз.",
  "data": null
}
"""
