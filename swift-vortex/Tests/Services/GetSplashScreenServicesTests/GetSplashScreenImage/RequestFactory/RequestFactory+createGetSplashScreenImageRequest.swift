//
//  RequestFactory+createGetSplashScreenTimePeriodsTests.swift
//
//
//  Created by Nikolay Pochekuev on 04.03.2025.
//

import GetSplashScreenServices
import RemoteServices
import XCTest

final class RequestFactory_createGetSplashScreenImageRequest: XCTestCase {
    
    func test_createRequest_shouldSetURLWithParameter() throws {
        
        let (url, splash) = (anyURL(), anyMessage())
        let request = try createRequest(url: url, splash: splash)
        
        XCTAssertNoDiff(request.url?.absoluteString, "\(url.absoluteString)?splash=\(splash)")
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
        url: URL = anyURL(),
        splash: String = UUID().uuidString
    ) throws -> URLRequest {
        
        return try RequestFactory.createGetSplashScreenImageRequest(
            url: url,
            splash: splash
        )
    }
}
