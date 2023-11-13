//
//  MapShowCVVResponseTests.swift
//  
//
//  Created by Igor Malyarov on 15.10.2023.
//

import CVVPINServices
import XCTest

func unimplemented<T>(
    _ message: String = "",
    file: StaticString = #file,
    line: UInt = #line
) -> T {
    
    fatalError("Unimplemented: \(message)", file: file, line: line)
}

final class MapShowCVVResponseTests: XCTestCase {
    
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
            
            assert(result, .failure(.error(
                statusCode: serverStatusCode,
                errorMessage: errorMessage
            )))
        }
    }
    
    func test_map_shouldDeliverSuccessOnResponse200AndValidData() throws {
        
        let cvv = UUID().uuidString
        let validData = try JSONSerialization.data(withJSONObject: [
            "cvv": cvv
        ])
        let response200 = anyHTTPURLResponse(with: 200)
        
        let result = map(validData, response200)
        
        assert(result, .success(.init(cvv)))
    }
    
    // MARK: - Helpers
    
    private typealias ShowCVVResult = ResponseMapper.ShowCVVResult
    
    private func map(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> ShowCVVResult {
        
        ResponseMapper.mapShowCVVResponse(data, httpURLResponse)
    }
    
    private func assert(
        _ received: ShowCVVResult,
        _ expected: ShowCVVResult,
        _ message: @autoclosure () -> String = "",
        file: StaticString = #file,
        line: UInt = #line
    ) {
        switch (received, expected) {
        case let (
            .failure(received),
            .failure(expected)
        ):
            XCTAssertEqual(received.view, expected.view, file: file, line: line)
            
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
}

private extension ResponseMapper.ShowCVVMapperError {
    
    var view: View {
        
        switch self {
        case let .invalidData(statusCode, data):
            return .invalidData(statusCode: statusCode, data: data)
            
        case let .error(statusCode, errorMessage):
            return .error(statusCode: statusCode, errorMessage: errorMessage)
        }
    }
    
    enum View: Equatable {
        
        case invalidData(statusCode: Int, data: Data)
        case error(statusCode: Int, errorMessage: String)
    }
}
