//
//  RequestFactory+createGetSplashScreenTimePeriodsTests.swift
//
//
//  Created by Nikolay Pochekuev on 18.02.2025.
//

import GetSplashScreenServices
import RemoteServices
import XCTest

final class RequestFactory_createGetSplashScreenTimePeriodsTests: XCTestCase {
    
    func test_createRequest_shouldSetURL() throws {
        
        let url = anyURL()
        let request = try createRequest(url: url)
        
        XCTAssertNoDiff(request.url, url)
    }
    
    func test_createRequest_shouldSetHTTPMethodToGet() throws {
        
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
        
        RequestFactory.createGetSplashScreenTimePeriodsRequest(url: url)
    }
}
