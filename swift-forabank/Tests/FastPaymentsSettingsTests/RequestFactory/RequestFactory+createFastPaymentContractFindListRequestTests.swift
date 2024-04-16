//
//  RequestFactory+createFastPaymentContractFindListRequestTests.swift
//  
//
//  Created by Igor Malyarov on 29.12.2023.
//

import FastPaymentsSettings
import RemoteServices
import XCTest

final class RequestFactory_createFastPaymentContractFindListRequestTests: XCTestCase {
    
    func test_createRequest_shouldSetURL() {
        
        let url = anyURL()
        let request = createRequest(url: url)
        
        XCTAssertNoDiff(request.url, url)
    }
    
    func test_createRequest_shouldSetHTTPMethodToGET() {
        
        let request = createRequest()
        
        XCTAssertNoDiff(request.httpMethod, "GET")
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
        
        RequestFactory.createFastPaymentContractFindListRequest(url: url)
    }
}
