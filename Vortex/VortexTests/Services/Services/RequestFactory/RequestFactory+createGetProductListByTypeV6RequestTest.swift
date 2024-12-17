//
//  RequestFactory+createGetProductListByTypeV6RequestTest.swift
//  ForaBankTests
//
//  Created by Andryusina Nataly on 15.08.2024.
//

import XCTest
@testable import ForaBank

final class RequestFactory_createGetProductListByTypeV6RequestTests: XCTestCase {

    func test_createRequest_shouldSetRequestURL() throws {
        
        let request = try createRequest()
        
        XCTAssertEqual(
            request.url?.absoluteString,
            "https://pl.forabank.ru/dbo/api/v3/rest/v6/getProductListByType?productType=CARD"
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
    
    func test_createRequest_shouldSetTimeout() throws {
        
        let request = try createRequest(timeout: 120.0)
        
        XCTAssertEqual(request.timeoutInterval, 120.0)
    }

    // MARK: - Helpers
    
    private func createRequest(
        payload: ProductType = .card,
        timeout: TimeInterval = 0
    ) throws -> URLRequest {
        
        try ForaBank.RequestFactory.createGetProductListByTypeV6Request(payload, timeout)
    }
}
