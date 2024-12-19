//
//  RequestFactory_createGetServiceCategoryListRequestTests.swift
//  Vortex
//
//  Created by Nikolay Pochekuev on 30.09.2024.
//

import GetClientInformDataServices
import RemoteServices
import XCTest

final class RequestFactory_createGetAuthorizedZoneClientInformDataRequestTests: XCTestCase {
    
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
        
        try RequestFactory.createGetAuthorizedZoneClientInformData(url: url)
    }
}
