//
//  RequestFactory+createGetServiceCategoryListRequestTests.swift
//
//
//  Created by Igor Malyarov on 13.08.2024.
//

import ServiceCategoriesBackend
import RemoteServices
import XCTest

final class RequestFactory_createGetServiceCategoryListRequestTests: XCTestCase {
    
    func test_createRequest_shouldSetURL() throws {
        
        let url = anyURL()
        let request = try createRequest(url: url)
        
        XCTAssertNoDiff(request.url, url)
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
        
        try RequestFactory.createGetServiceCategoryListRequest(url: url)
    }
}
