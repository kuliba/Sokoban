//
//  RequestFactory+createGetShowcaseRequestTestsTests.swift
//  swift-forabank
//
//  Created by Valentin Ozerov on 08.10.2024.
//

import RemoteServices
import XCTest
import CollateralLoanLandingGetShowcaseBackend

final class RequestFactory_createGetShowcaseRequestTests: XCTestCase {

    func test_createRequest_shouldSetHTTPMethodToGET() {
        
        let request = createRequest()
        
        XCTAssertNoDiff(request.httpMethod, "GET")
    }
    
    func test_createRequest_shouldSetCachePolicy() {
        
        let request = createRequest()
        
        XCTAssertNoDiff(request.cachePolicy, .reloadIgnoringLocalAndRemoteCacheData)
    }
    
    func test_createRequest_shouldSetNilHTTPBody() {
        
        let request = createRequest()
        
        XCTAssertNil(request.httpBody)
    }
    
    // MARK: - Helpers
    
    private func createRequest(url: URL = anyURL()) -> URLRequest {
        
        RequestFactory.createGetShowcaseRequest(url: url)
    }
}

private extension URL {
    var queryParameters: [String: String]? {
        guard
            let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
    }
}
