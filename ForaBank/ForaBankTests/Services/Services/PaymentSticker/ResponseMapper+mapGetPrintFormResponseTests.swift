//
//  ResponseMapper+mapGetPrintFormResponseTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 22.11.2023.
//

@testable import ForaBank
import XCTest

final class ResponseMapper_mapGetPrintFormResponseTests: XCTestCase {
    
    func test_map_shouldDeliverInvalidDataErrorOnInvalidData() {
        
        let invalidData = Data("invalid data".utf8)
        let codes = [199, 200, 201, 399, 400, 401, 404, 500]
        
        for code in codes {
            
            let result = map(
                invalidData,
                anyHTTPURLResponse(with: code)
            )
            
            assert(result, .failure(.invalidData(statusCode: code, data: invalidData)))
        }
    }
    
    func test_map_shouldDeliverServerErrorOnNon200AndValidData() throws {
        
        let serverStatusCode = 7512
        let errorMessage = "Возникла техническая ошибка 7512. Свяжитесь с поддержкой банка для уточнения"
        let validData = makeServerErrorData(
            statusCode: serverStatusCode,
            errorMessage: errorMessage
        )
        let non200Codes = [199, 201, 399, 400, 401, 404, 500]
        
        for code in non200Codes {
            
            let result = map(
                validData,
                anyHTTPURLResponse(with: code)
            )
            
            assert(result, .failure(.server(
                statusCode: serverStatusCode,
                errorMessage: errorMessage
            )))
        }
    }
    
    func test_map_shouldDeliverErrorOnResponse200AndValidDataAndNonNilErrorMessage() throws {
        
        let serverStatusCode = 7512
        let errorMessage = "Возникла техническая ошибка 7512. Свяжитесь с поддержкой банка для уточнения"
        let validData = try makeValidResponse(
            serverStatusCode: serverStatusCode,
            errorMessage: errorMessage,
            data: anyData()
        )
        let response200 = anyHTTPURLResponse(with: 200)
        
        let result = map(validData, response200)
        
        assert(result, .failure(.server(
            statusCode: serverStatusCode,
            errorMessage: errorMessage
        )))
    }
    
    func test_map_shouldDeliverSuccessOnResponse200AndValidData() throws {
        
        let data = anyData()
        let validData = try makeValidResponse(data: data)
        let response200 = anyHTTPURLResponse(with: 200)
        
        let result = map(validData, response200)
        
        assert(result, .success(data))
    }
    
    // MARK: - Helpers
    
    private typealias GetPrintFormResult = ResponseMapper.GetPrintFormResult
    
    private func map(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> GetPrintFormResult {
        
        ResponseMapper.mapGetPrintFormResponse(data, httpURLResponse)
    }
    
    private func makeValidResponse(
        serverStatusCode: Int = 7512,
        errorMessage: String? = nil,
        data: Data? = nil
    ) throws -> Data {
        
        try JSONEncoder().encode(Response(
            statusCode: serverStatusCode,
            errorMessage: errorMessage,
            data: data
        ))
    }

    private func assert(
        _ received: GetPrintFormResult,
        _ expected: GetPrintFormResult,
        _ message: @autoclosure () -> String = "",
        file: StaticString = #file,
        line: UInt = #line
    ) {
        switch (received, expected) {
        case let (
            .failure(received),
            .failure(expected)
        ):
            XCTAssertEqual(received.equatable, expected.equatable, file: file, line: line)
            
        case let (
            .success(received),
            .success(expected)
        ):
            XCTAssertEqual(received, expected, file: file, line: line)
            
        default:
            XCTFail(
                "\nReceived \"\(received)\", but expected \(expected).",
                file: file, line: line
            )
        }
    }
    
    private struct Response: Encodable {
        
        let statusCode: Int
        let errorMessage: String?
        let data: Data?
    }
}

private extension ResponseMapper.GetPrintFormError {
    
    var equatable: EquatableError {
        
        switch self {
        case let .invalidData(statusCode, data):
            return .invalidData(statusCode: statusCode, data: data)
            
        case let .server(statusCode, errorMessage):
            return .server(statusCode: statusCode, errorMessage: errorMessage)
        }
    }
    
    enum EquatableError: Equatable {
        
        case invalidData(statusCode: Int, data: Data)
        case server(statusCode: Int, errorMessage: String)
    }
}
