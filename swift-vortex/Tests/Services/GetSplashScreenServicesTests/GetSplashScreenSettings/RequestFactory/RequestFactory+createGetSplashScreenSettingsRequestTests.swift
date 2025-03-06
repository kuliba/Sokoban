//
//  RequestFactory+createGetSplashScreenSettingsRequestTests.swift
//
//
//  Created by Igor Malyarov on 06.03.2025.
//

import GetSplashScreenServices
import RemoteServices
import XCTest

final class RequestFactory_createGetSplashScreenSettingsRequestTests: XCTestCase {
    
    func test_createRequest_shouldSetURLWithParameter() throws {
        
        let (url, timePeriod) = (anyURL(), anyMessage())
        let request = try createRequest(url: url, timePeriod: timePeriod)
        
        XCTAssertNoDiff(request.url?.absoluteString, "\(url.absoluteString)?enum=\(timePeriod)")
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
        timePeriod: String = UUID().uuidString
    ) throws -> URLRequest {
        
        return try RequestFactory.createGetSplashScreenSettingsRequest(
            url: url,
            timePeriod: timePeriod
        )
    }
}
