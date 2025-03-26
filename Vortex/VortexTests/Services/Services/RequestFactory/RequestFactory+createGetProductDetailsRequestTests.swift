//
//  RequestFactory+createGetProductDetailsRequestTests.swift
//  VortexTests
//
//  Created by Nikolay Pochekuev on 21.03.2025.
//

@testable import Vortex
import AccountInfoPanel
import XCTest

final class RequestFactory_createGetProductDetailsRequestTests: XCTestCase {
    
    func test_createRequest_shouldSetV3() throws {
                
        try  XCTAssertTrue(XCTUnwrap(createRequest().url).absoluteString.contains("rest/v3"))
    }
    
    // MARK: - Helpers
    
    private func createRequest(
        payload: ProductDetailsPayload = .cardId(1)
    ) throws -> URLRequest {
        
        return try RequestFactory.createGetProductDetailsRequest(payload: payload)
    }
}
