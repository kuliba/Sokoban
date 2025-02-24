//
//  RequestFactory_createPrepareOpenSavingsAccountRequestTests.swift
//  VortexTests
//
//  Created by Andryusina Nataly on 19.02.2025.
//

import XCTest
@testable import Vortex

final class RequestFactory_createPrepareOpenSavingsAccountRequestTests: XCTestCase {

    func test_createRequest_shouldSetRequestURL() throws {
        
        let request = try createRequest()
        
        XCTAssertEqual(
            request.url?.absoluteString,
            "https://pl.\(Config.domen)/dbo/api/v3/rest/prepareOpenSavingsAccount"
        )
    }
    
    func test_createRequest_shouldSetRequestMethodToPost() throws {
        
        let request = try createRequest()
        
        XCTAssertEqual(request.httpMethod, "POST")
    }
    
    func test_createRequest_shouldSetRequestBodyToNil() throws {
        
        let request = try createRequest()
        
        XCTAssertNil(request.httpBody)
    }
    
    // MARK: - Helpers
    
    private func createRequest() throws -> URLRequest {
        
        try Vortex.RequestFactory.createPrepareOpenSavingsAccountRequest()
    }
}
