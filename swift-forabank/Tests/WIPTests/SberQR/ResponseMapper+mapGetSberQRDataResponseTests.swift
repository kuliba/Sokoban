//
//  ResponseMapper+mapGetSberQRDataResponseTests.swift
//
//
//  Created by Igor Malyarov on 03.12.2023.
//

import XCTest

final class ResponseMapper_mapGetSberQRDataResponseTests: GetSberQRDataResponseTests {
    
    func test_mapGetSberQRDataResponse_shouldDeliverInvalidErrorOnInvalidData() throws {
        
        let invalidData = anyData()
        
        let result = try map(invalidData)
        
        assert(result, equals: .failure(.invalid(statusCode: 200, data: invalidData)))
    }
    
    func test_mapGetSberQRDataResponse_shouldDeliverServerErrorOnNilData() throws {
        
        let result = try map(jsonWithError)
        
        assert(result, equals: .failure(.server(
            statusCode: 102,
            errorMessage: "Возникла техническая ошибка"
        )))
    }
    
    func test_mapGetSberQRDataResponse_shouldDeliverServerErrorOnServerErrorWithNonOkHTTPURLResponseStatusCode() throws {
        
        let nonOkResponse = anyHTTPURLResponse(statusCode: 400)
        let result = try map(jsonWithError, nonOkResponse)
        
        assert(result, equals: .failure(.server(
            statusCode: 102,
            errorMessage: "Возникла техническая ошибка"
        )))
    }
    
    func test_mapGetSberQRDataResponse_shouldDeliverInvalidOnNonOKHTTPURLResponseStatusCode() throws {
        
        let statusCode = 400
        let data = anyData()
        let nonOkResponse = anyHTTPURLResponse(statusCode: statusCode)
        let result = try map(data, nonOkResponse)
        
        assert(result, equals: .failure(.invalid(statusCode: statusCode, data: data)))
    }
    
    func test_mapGetSberQRDataResponse_shouldDeliverResponseWithAmount() throws {
        
        let result = try map(jsonWithAmount)
        
        assert(result, equals: .success(.init(
            qrcID: "04a7ae2bee8f4f13ab151c1e6066d304",
            parameters: [
                header(),
                debitAccount(),
                brandName(value: "сббол енот_QR"),
                amount(),
                recipientBank(),
                buttonPay(),
            ],
            required: [
                .debitAccount
            ]
        )))
    }
    
    func test_mapGetSberQRDataResponse_shouldDeliverResponseWithoutAmount() throws {
        
        let result = try map(jsonWithoutAmount)
        
        assert(result, equals: .success(.init(
            qrcID: "a6a05778867f439b822e7632036a9b45",
            parameters: [
                header(),
                debitAccount(),
                brandName(value: "Тест Макусов. Кутуза_QR"),
                recipientBank(),
                paymentAmount(),
                currency(),
            ],
            required: [
                .debitAccount,
                .paymentAmount,
                .currency
            ]
        )))
    }
    
    // MARK: - Helpers
    
    private func map(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse = anyHTTPURLResponse()
    ) throws -> ResponseMapper.GetSberQRDataResult {
        
        try ResponseMapper.mapGetSberQRDataResponse(
            data,
            httpURLResponse
        )
    }
    
    private func map(
        _ string: String,
        _ httpURLResponse: HTTPURLResponse = anyHTTPURLResponse()
    ) throws -> ResponseMapper.GetSberQRDataResult {
        
        try ResponseMapper.mapGetSberQRDataResponse(
            .init(string.utf8),
            httpURLResponse
        )
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
