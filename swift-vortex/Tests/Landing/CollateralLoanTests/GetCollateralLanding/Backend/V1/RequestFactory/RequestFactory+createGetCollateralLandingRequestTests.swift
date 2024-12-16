//
//  RequestFactory+createGetCollateralLandingRequestTests.swift
//  
//
//  Created by Valentin Ozerov on 29.11.2024.
//

import RemoteServices
import XCTest
import CollateralLoanLandingGetCollateralLandingBackend

final class RequestFactory_createGetCollateralLandingRequestTests: XCTestCase {
    
    func test_createGetCollateralLandingRequestTests_shouldSetHTTPMethodToGET() throws {
        
        let request = try makeRequest()
        
        XCTAssertNoDiff(request.httpMethod, "GET")
    }
    
    func test_createGetCollateralLandingRequestTests_shouldSetCachePolicy() throws {

        let request = try makeRequest()
        
        XCTAssertNoDiff(request.cachePolicy, .reloadIgnoringLocalAndRemoteCacheData)
    }

    func test_createGetCollateralLandingRequestTests_shouldCreateValidURL() throws {

        let request = try makeRequest()

        _ = try XCTUnwrap(request.url)
    }

    func test_createGetCollateralLandingRequestTests_shouldSetNilHTTPBody() throws {
        
        let request = try makeRequest()
        
        XCTAssertNil(request.httpBody)
    }

    // MARK: Helpers
    
    private func makeRequest(
        _ url: URL = anyURL()
    ) throws -> URLRequest {

        try RequestFactory.createGetCollateralLandingRequest(url: url)
    }
}
