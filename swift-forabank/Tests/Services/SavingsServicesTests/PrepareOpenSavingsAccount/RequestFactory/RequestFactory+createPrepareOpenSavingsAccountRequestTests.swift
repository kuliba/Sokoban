//
//  RequestFactory+createPrepareOpenSavingsAccountRequestTests.swift
//
//
//  Created by Andryusina Nataly on 25.11.2024.
//

import SavingsServices
import RemoteServices
import XCTest

final class RequestFactory_createPrepareOpenSavingsAccountRequestTests: XCTestCase {
    
    func test_createRequest_shouldSetURL() {
        
        let url = anyURL()
        let request = createRequest(url: url)
        
        XCTAssertNoDiff(request.url?.absoluteString, url.absoluteString)
    }
    
    func test_createRequest_shouldSetHTTPMethodToGET() {
        
        let request = createRequest()
        
        XCTAssertNoDiff(request.httpMethod, "POST")
    }
    
    func test_createRequest_shouldSetCachePolicy() {
        
        let request = createRequest()
        
        XCTAssertNoDiff(request.cachePolicy, .reloadIgnoringLocalAndRemoteCacheData)
    }
    
    func test_createRequest_shouldSetNilHTTPBody() {
        
        XCTAssertNil(createRequest().httpBody)
    }
    
    // MARK: - Helpers
    
    private func createRequest(
        url: URL = anyURL()
    ) -> URLRequest {
        
        RequestFactory.createPrepareOpenSavingsAccountRequest(url: url)
    }
}
