//
//  RequestFactory+createGetShowcaseRequestTests.swift
//  VortexTests
//
//  Created by Valentin Ozerov on 27.11.2024.
//

@testable import ForaBank
import XCTest

final class RequestFactory_createGetShowcaseRequestTests: XCTestCase {
    
    func test_createRequest_shouldSetRequestURL() throws {
        
        let serial = UUID().uuidString
        let request = try createRequest(serial)
        
        XCTAssertNoDiff(
            request.url?.absoluteString,
            "https://pl.forabank.ru/dbo/api/v3/rest/v1/pages/collateral/getShowcase?serial=\(serial)"
        )
    }

    func test_createRequest_shouldSetRequestMethodToGet() throws {
        
        let request = try createRequest()
        
        XCTAssertEqual(request.httpMethod, "GET")
    }
    
    func test_createRequest_shouldSetRequestBodyToNil() throws {
        
        let request = try createRequest()
        
        XCTAssertNil(request.httpBody)
    }
    
    // MARK: - Helpers
    
    private func createRequest(
        _ serial: String = UUID().uuidString
    ) throws -> URLRequest {
        
        try RequestFactory.createGetShowcaseRequest(serial: serial)
    }
}
