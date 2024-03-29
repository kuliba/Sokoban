//
//  RequestFactory+createGetProductListByTypeRequestTest.swift
//  ForaBankTests
//
//  Created by Andryusina Nataly on 27.03.2024.
//

import XCTest
@testable import ForaBank

final class RequestFactory_createGetProductListByTypeRequestTests: XCTestCase {

    func test_createRequest_shouldSetRequestURL() throws {
        
        let request = try createRequest()
        
        XCTAssertEqual(
            request.url?.absoluteString,
            "https://pl.forabank.ru/dbo/api/v3/rest/v5/getProductListByType?productType=CARD"
        )
    }
    
    func test_createRequest_shouldSetRequestMethodToPost() throws {
        
        let request = try createRequest()
        
        XCTAssertEqual(request.httpMethod, "GET")
    }
    
    func test_createRequest_shouldSetRequestBodyToNil() throws {
        
        let request = try createRequest()
        
        XCTAssertNil(request.httpBody)
    }

    // MARK: - Helpers
    
    private func createRequest(
        payload: ProductType = .card
    ) throws -> URLRequest {
        
        try ForaBank.RequestFactory.createGetProductListByTypeRequest(payload)
    }
}
