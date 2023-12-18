//
//  ResponseMapper+mapGetSberQRDataResponseTests.swift
//
//
//  Created by Igor Malyarov on 03.12.2023.
//

import SberQR
import XCTest

final class ResponseMapper_mapGetSberQRDataResponseTests: GetSberQRDataResponseTests {
    
    func test_mapGetSberQRDataResponse_shouldDeliverInvalidErrorOnInvalidData() throws {
        
        let invalidData = anyData()
        
        let result = map(invalidData)
        
        assert(result, equals: .failure(.invalid(
            statusCode: 200,
            data: invalidData
        )))
    }
    
    func test_mapGetSberQRDataResponse_shouldDeliverServerErrorOnNilData() throws {
        
        let result = map(jsonWithError)
        
        assert(result, equals: .failure(.server(
            statusCode: 102,
            errorMessage: "Возникла техническая ошибка"
        )))
    }
    
    func test_mapGetSberQRDataResponse_shouldDeliverServerErrorOnServerErrorWithNonOkHTTPURLResponseStatusCode() throws {
        
        let nonOkResponse = anyHTTPURLResponse(statusCode: 400)
        let result = map(jsonWithError, nonOkResponse)
        
        assert(result, equals: .failure(.server(
            statusCode: 102,
            errorMessage: "Возникла техническая ошибка"
        )))
    }
    
    func test_mapGetSberQRDataResponse_shouldDeliverInvalidOnNonOKHTTPURLResponseStatusCode() throws {
        
        let statusCode = 400
        let data = anyData()
        let nonOkResponse = anyHTTPURLResponse(statusCode: statusCode)
        let result = map(data, nonOkResponse)
        
        assert(result, equals: .failure(.invalid(
            statusCode: statusCode,
            data: data
        )))
    }
    
    func test_mapGetSberQRDataResponse_shouldDeliverResponseWithAmount() throws {
        
        let result = map(jsonWithAmount)
        
        assert(result, equals: .success(responseWithFixedAmount()))
    }
    
    func test_mapGetSberQRDataResponse_shouldDeliverResponseWithoutAmount() throws {
        
        let result = map(jsonWithoutAmount)
        
        assert(result, equals: .success(responseWithEditableAmount(amount: 0)))
    }
    
    func test_mapGetSberQRDataResponse_getSberQRData_any_sum() throws {
        
        let result = try map(getSberQRData_any_sumURL)
        
        assert(result, equals: .success(responseWithEditableAmount(
            qrcID: "fa0926661ff048658407b4b57a35fc66",
            brand: "Тест Макусов. Кутуза_07",
            amount: 0
        )))
    }
    
    func test_mapGetSberQRDataResponse_getSberQRData_fix_sum() throws {
        
        let result = try map(getSberQRData_fix_sumURL)
        
        assert(result, equals: .success(responseWithFixedAmount(
            qrcID: "48b1446882844284bc6bac9bb3e5062d"
        )))
    }
    
    // MARK: - Helpers
    
    private func map(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse = anyHTTPURLResponse()
    ) -> ResponseMapper.GetSberQRDataResult {
        
        ResponseMapper.mapGetSberQRDataResponse(
            data,
            httpURLResponse
        )
    }
    
    private func map(
        _ string: String,
        _ httpURLResponse: HTTPURLResponse = anyHTTPURLResponse()
    ) -> ResponseMapper.GetSberQRDataResult {
        
        map(Data(string.utf8), httpURLResponse)
    }
    
    private func map(
        _ filename: URL?,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> ResponseMapper.GetSberQRDataResult {
        
        let url = try XCTUnwrap(filename, file: file, line: line)
        let contents = try Data(contentsOf: url)
        
        return map(contents, anyHTTPURLResponse())
    }
    
    private func assert(
        _ receivedResult: ResponseMapper.GetSberQRDataResult,
        equals expectedResult: ResponseMapper.GetSberQRDataResult,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        switch (receivedResult, expectedResult) {
        case let (
            .failure(received),
            .failure(expected)
        ):
            XCTAssertNoDiff(received, expected, file: file, line: line)
            
        case let (
            .success(received),
            .success(expected)
        ):
            XCTAssertNoDiff(received, expected, file: file, line: line)
            
        default:
            XCTFail("\nExpected \(expectedResult), but got \(receivedResult) instead.", file: file, line: line)
        }
    }
}
