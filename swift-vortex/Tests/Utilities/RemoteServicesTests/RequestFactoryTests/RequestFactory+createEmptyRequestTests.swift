//
//  RequestFactory+createEmptyRequestTests.swift
//  
//
//  Created by Igor Malyarov on 25.03.2024.
//

import RemoteServices
import XCTest

final class RequestFactory_createEmptyRequestTests: XCTestCase {
    
    func test_createRequest_shouldSetURL() {
        
        let url = anyURL()
        let request = createRequest(url: url)
        
        XCTAssertNoDiff(request.url, url)
    }
    
    func test_createRequest_shouldSetHTTPMethodToGet() {
        
        let request = createRequest(.get)
        
        XCTAssertNoDiff(request.httpMethod, "GET")
    }
    func test_createRequest_shouldSetHTTPMethodToPOST() {
        
        let request = createRequest(.post)
        
        XCTAssertNoDiff(request.httpMethod, "POST")
    }
    
    func test_createRequest_shouldSetCachePolicy() {
        
        let request = createRequest()
        
        XCTAssertNoDiff(request.cachePolicy, .reloadIgnoringLocalAndRemoteCacheData)
    }
    
    func test_createRequest_shouldSetHTTPBodyToNil() throws {
        
        let request = createRequest()
     
        XCTAssertNil(request.httpBody)
    }
    
    // MARK: - Helpers
    
    private func createRequest(
        _ httpMethod: URLRequest.HTTPMethod = .post,
        url: URL = anyURL()
    ) -> URLRequest {
        
        RequestFactory.createEmptyRequest(httpMethod, with: url)
    }
}
