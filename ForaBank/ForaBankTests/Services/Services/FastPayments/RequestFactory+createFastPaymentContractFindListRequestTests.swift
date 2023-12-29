//
//  RequestFactory+createFastPaymentContractFindListRequestTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 29.12.2023.
//

import Foundation

extension RequestFactory {
    
    static func createFastPaymentContractFindListRequest(
        url: URL
    ) -> URLRequest {
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        return request
    }
}

@testable import ForaBank
import XCTest

final class RequestFactory_createFastPaymentContractFindListRequestTests: XCTestCase {
    
    func test_makeRequest_shouldSetURL() {
        
        let url = anyURL()
        let request = makeRequest(url: url)
        
        XCTAssertNoDiff(request.url, url)
    }
    
    func test_makeRequest_shouldSetHTTPMethodToGET() {
        
        let request = makeRequest()
        
        XCTAssertNoDiff(request.httpMethod, "GET")
    }
    
    func test_makeRequest_shouldSetCachePolicy() {
        
        let request = makeRequest()
        
        XCTAssertNoDiff(request.cachePolicy, .reloadIgnoringLocalAndRemoteCacheData)
    }
    
    // MARK: - Helpers
    
    private func makeRequest(
        url: URL = anyURL(string: "any-url")
    ) -> URLRequest {
        
        RequestFactory.createFastPaymentContractFindListRequest(url: url)
    }
}
