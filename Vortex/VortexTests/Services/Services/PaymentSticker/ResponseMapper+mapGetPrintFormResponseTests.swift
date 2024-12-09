//
//  ResponseMapper+mapGetPrintFormResponseTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 22.11.2023.
//

@testable import Vortex
import XCTest

final class ResponseMapper_mapGetPrintFormResponseTests: XCTestCase {
    
    func test_map_shouldDeliverErrorOnNon200() throws {
        
        let non200Codes = [199, 201, 399, 400, 401, 404, 500]
        
        for code in non200Codes {
            
            let result = map(
                anyData(),
                anyHTTPURLResponse(with: code)
            )
            
            assert(result, .failure(.init()))
        }
    }
    
    func test_map_shouldDeliverSuccessOnResponse200() throws {
        
        let data = anyData()
        let response200 = anyHTTPURLResponse(with: 200)
        let result = map(data, response200)
        
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
        
        .init()
    }
    
    struct EquatableError: Equatable {}
}
