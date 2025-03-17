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
    
    func test_createRequest_shouldSetURLStringV3() throws {
        
        let url = anyURL(string: "https://pl.\(Config.domen)/dbo/api/v3/rest/v3/getProductDetails")
        let request = try createRequest(url: url)
        
        XCTAssertNoDiff(request.url?.absoluteString, url.absoluteString)
    }
    
    // MARK: - Helpers
    
    private func createRequest(
        url: URL = anyURL(),
        payload: ProductDetailsPayload = .cardId(1)
    ) throws -> URLRequest {
        
        return try RequestFactory.createGetProductDetailsRequest(payload: payload)
    }
}
