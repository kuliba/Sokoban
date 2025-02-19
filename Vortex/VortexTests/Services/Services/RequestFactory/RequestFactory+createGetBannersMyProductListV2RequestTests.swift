//
//  RequestFactory+createGetBannersMyProductListV2RequestTests.swift
//  VortexTests
//
//  Created by Andryusina Nataly on 17.02.2025.
//

import XCTest
@testable import Vortex

final class RequestFactory_createGetBannersMyProductListV2RequestTests: XCTestCase {

    func test_createRequest_shouldSetRequestURL() throws {
        
        let serial = anyMessage()
        let request = try createRequest(serial: serial)
        
        XCTAssertEqual(
            request.url?.absoluteString,
            "https://pl.\(Config.domen)/dbo/api/v3/dict/v2/getBannersMyProductList?serial=\(serial)"
        )
    }
    
    func test_createRequest_shouldSetRequestMethodToPost() throws {
        
        let request = try createRequest()
        
        XCTAssertEqual(request.httpMethod, "GET")
    }
    
    func test_createRequest_shouldSetRequestBodyToNil() throws {
        
        let request = try createRequest()
        
        XCTAssertNil(request.httpBody)
    }
    
    func test_createRequest_shouldSetTimeout() throws {
        
        let request = try createRequest(timeout: 120.0)
        
        XCTAssertEqual(request.timeoutInterval, 120.0)
    }

    // MARK: - Helpers
    
    private func createRequest(
        serial: String? = nil,
        timeout: TimeInterval = 0
    ) throws -> URLRequest {
        
        try Vortex.RequestFactory.createGetBannersMyProductListV2Request(serial, timeout)
    }
}
