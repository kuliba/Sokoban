//
//  RequestFactory+createGetBannerCatalogListV2Tests.swift
//  ForaBankTests
//
//  Created by Andryusina Nataly on 03.09.2024.
//

import XCTest
@testable import ForaBank

final class RequestFactory_createGetBannerCatalogListV2RequestTests: XCTestCase {

    func test_createRequest_shouldSetRequestURL() throws {
        
        let serial = "111"
        let request = try createRequest(serial: serial)
        
        XCTAssertEqual(
            request.url?.absoluteString,
            "https://pl.forabank.ru/dbo/api/v3/dict/v2/getBannerCatalogList?serial=\(serial)"
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
        
        try ForaBank.RequestFactory.createGetBannerCatalogListV2Request(serial, timeout)
    }
}
