//
//  RequestFactory+createGetCardShowRequestTests.swift
//  VortexTests
//
//  Created by Дмитрий Савушкин on 10.03.2025.
//

@testable import Vortex
import RemoteServices
import XCTest

final class RequestFactory_createGetCardShowRequestTests: XCTestCase {
    
    func test_createRequest_shouldSetRequestURL() throws {
        
        try XCTAssertNoDiff(
            createRequest().url?.removingQueryItems?.absoluteString,
            "https://pl.\(Config.domen)/dbo/api/v3/rest/v2/pages/order-card/getCardShowcase"
        )
    }
    
    func test_createRequest_shouldSetHTTPMethodToGET() throws {
        
        try XCTAssertNoDiff(createRequest().httpMethod, "GET")
    }
    
    func test_createRequest_shouldSetCachePolicy() throws {
        
        try XCTAssertNoDiff(createRequest().cachePolicy, .reloadIgnoringLocalAndRemoteCacheData)
    }
    
    func test_createRequest_shouldNotSetHTTPBody() throws {
        
        try XCTAssertNil(createRequest().httpBody)
    }
    
    // MARK: - Helpers
    
    private func createRequest(
    ) throws -> URLRequest {
        
        try Vortex.RequestFactory.createGetCardShowCaseRequest()
    }
}
