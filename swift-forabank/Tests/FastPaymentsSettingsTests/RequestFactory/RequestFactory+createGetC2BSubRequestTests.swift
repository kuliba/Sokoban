//
//  RequestFactory+createGetC2BSubRequestTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 29.12.2023.
//

import Foundation

extension RequestFactory {
    
    static func createGetC2BSubRequest(
        url: URL
    ) -> URLRequest {
        
        createEmptyRequest(.post, with: url)
    }
}

import XCTest

final class RequestFactory_createGetC2BSubRequestTests: XCTestCase {
    
    func test_createRequest_shouldSetURL() {
        
        let url = anyURL()
        let request = createRequest(url: url)
        
        XCTAssertNoDiff(request.url, url)
    }
    
    func test_createRequest_shouldSetHTTPMethodToPOST() {
        
        let request = createRequest()
        
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
        url: URL = anyURL()
    ) -> URLRequest {
        
        RequestFactory.createGetC2BSubRequest(url: url)
    }
}
