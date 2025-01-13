//
//  RequestFactory_createPrepareDeleteBankDefaultRequestTests.swift
//
//
//  Created by Дмитрий Савушкин on 29.09.2024.
//

import FastPaymentsSettings
import RemoteServices
import XCTest

final class RequestFactory_createPrepareDeleteBankDefaultRequestTests: XCTestCase {
    
    func test_createRequest_shouldSetURL() {
        
        let url = anyURL()
        let request = createRequest(url: url)
        
        XCTAssertNoDiff(request.url, url)
    }
    
    func test_createRequest_shouldSetHTTPMethodToGET() {
        
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

        
        RequestFactory.createPrepareDeleteBankDefaultRequest(url: url)
    }
}
