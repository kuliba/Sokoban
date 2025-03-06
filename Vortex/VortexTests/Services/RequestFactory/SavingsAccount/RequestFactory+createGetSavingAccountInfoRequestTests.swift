//
//  RequestFactory+createGetSavingAccountInfoRequestTests.swift
//  VortexTests
//
//  Created by Andryusina Nataly on 05.03.2025.
//

import XCTest
@testable import Vortex

final class RequestFactory_createGetSavingAccountInfoRequestTests: XCTestCase {
    
    func test_createRequest_shouldSetRequestURL() throws {
        
        let request = try createRequest()
        
        XCTAssertNoDiff(
            request.url?.absoluteString,
            "https://pl.\(Config.domen)/dbo/api/v3/rest/v2/getSavingAccountInfo"
        )
    }
    
    func test_createRequest_shouldSetRequestMethodToPost() throws {
        
        let request = try createRequest()
        
        XCTAssertEqual(request.httpMethod, "POST")
    }
    
    func test_createRequest_shouldSetRequestBody() throws {
        
        let accountNumber = anyMessage()
        let request = try createRequest(accountNumber: accountNumber)
        
        let decodedRequest = try JSONDecoder().decode(
            Payload.self,
            from: XCTUnwrap(request.httpBody)
        )
        
        XCTAssertNoDiff(decodedRequest.accountNumber, accountNumber)
    }
    
    // MARK: - Helpers
    
    private func createRequest(
        accountNumber: String = "1"
    ) throws -> URLRequest {
        
        try Vortex.RequestFactory.createGetSavingsAccountInfoRequest(payload: .init(accountNumber: accountNumber))
    }
}

private struct Payload: Decodable {
    
    let accountNumber: String
}
