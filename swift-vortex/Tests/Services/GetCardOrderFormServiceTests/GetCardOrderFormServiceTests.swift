//
//  GetCardOrderFormServiceTests.swift
//
//
//  Created by Дмитрий Савушкин on 11.12.2024.
//

import GetCardOrderFormService
import XCTest
import RemoteServices

final class RequestFactory_createGetCardOrderFormRequestTests: XCTestCase {
    
    func test_createRequest_shouldSetURL() throws {
        
        let url = anyURL()
        let request = try createRequest(url: url)
        
        XCTAssertNoDiff(request.url?.absoluteString, "\(url.absoluteString)")
    }

    func test_createRequest_shouldSetHTTPMethodToGET() throws {
        
        let request = try createRequest()
        
        XCTAssertNoDiff(request.httpMethod, "GET")
    }
    
    func test_createRequest_shouldSetCachePolicy() throws {
        
        let request = try createRequest()
        
        XCTAssertNoDiff(request.cachePolicy, .reloadIgnoringLocalAndRemoteCacheData)
    }
    
    func test_createRequest_shouldSetNilHTTPBody() throws {
        
        try XCTAssertNil(createRequest().httpBody)
    }
    
    // MARK: - Helpers
    
    private func createRequest(
        url: URL = anyURL()
    ) throws -> URLRequest {
        
        try RequestFactory.createGetCardOrderFormRequest(url: url)
    }
}

