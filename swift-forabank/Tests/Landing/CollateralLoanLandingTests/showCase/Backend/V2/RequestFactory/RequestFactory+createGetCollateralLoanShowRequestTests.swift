//
//  RequestFactory+createGetCollateralLoanShowRequestTests.swift
//  swift-forabank
//
//  Created by Valentin Ozerov on 08.10.2024.
//

import RemoteServices
import XCTest
import CollateralLoanLanding

final class RequestFactory_createGetCollateralLoanShowRequestTests: XCTestCase {
    func test_createRequest_shouldSetURLWithOneParameter() throws {
        let parameters = ["type": "COLLATERAL_SHOWCASE"]
        let url = anyURL()
        let request = try createRequest(parameters: parameters, url: url)
        
        XCTAssertNoDiff(request.url?.absoluteString, url.absoluteString + "?type=COLLATERAL_SHOWCASE")
    }
    
    func test_createRequest_shouldSetHTTPMethodToGET() throws {
        
        let request = try createRequest(parameters: [:])
        
        XCTAssertNoDiff(request.httpMethod, "GET")
    }
    
    func test_createRequest_shouldSetCachePolicy() throws {
        
        let request = try createRequest(parameters: [:])
        
        XCTAssertNoDiff(request.cachePolicy, .reloadIgnoringLocalAndRemoteCacheData)
    }
    
    func test_createRequest_shouldSetNilHTTPBodyWithEmptyParameters() throws {
        
        let request = try createRequest(parameters: [:])
        
        XCTAssertNil(request.httpBody)
    }
    
    func test_createRequest_shouldSetNilHTTPBodyWithOneParameters() throws {
        
        let parameters = [anyMessage(): anyMessage()]
        let request = try createRequest(parameters: parameters)
        
        XCTAssertNil(request.httpBody)
    }
    
    // MARK: - Helpers
    
    private func createRequest(
        parameters: [String: String],
        url: URL = anyURL()
    ) throws -> URLRequest {
        
        try RequestFactory.createGetCollateralLoanLandingRequest(parameters: parameters, url: url)
    }
}
