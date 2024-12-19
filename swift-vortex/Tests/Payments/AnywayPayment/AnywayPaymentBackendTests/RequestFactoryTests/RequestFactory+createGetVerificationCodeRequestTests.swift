//
//  RequestFactory+createGetVerificationCodeRequestTests.swift
//
//
//  Created by Igor Malyarov on 25.03.2024.
//

import AnywayPaymentBackend
import RemoteServices
import XCTest

final class RequestFactory_createGetVerificationCodeRequestTests: XCTestCase {
    
    func test_createRequest_shouldSetURL() throws {
        
        let url = anyURL()
        let request = try createRequest(url: url)
        
        XCTAssertNoDiff(request.url, url)
    }
    
    func test_createRequest_shouldSetHTTPMethodToGET() throws {
        
        try XCTAssertNoDiff(createRequest().httpMethod, "GET")
    }
    
    func test_createRequest_shouldSetCachePolicy() throws {
        
        try XCTAssertNoDiff(
            createRequest().cachePolicy,
            .reloadIgnoringLocalAndRemoteCacheData
        )
    }
    
    func test_createRequest_shouldNotSetHTTPBody() throws {
        
        try XCTAssertNil(createRequest().httpBody)
    }
    
    // MARK: - Helpers
    
    private func createRequest(
        url: URL = anyURL()
    ) throws -> URLRequest {
        
        try RequestFactory.createGetVerificationCodeRequest(url: url)
    }
}
