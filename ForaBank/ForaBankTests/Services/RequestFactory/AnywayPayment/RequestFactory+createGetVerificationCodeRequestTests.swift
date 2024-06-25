//
//  RequestFactory+createGetVerificationCodeRequestTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 17.06.2024.
//

@testable import ForaBank
import RemoteServices
import XCTest

final class RequestFactory_createGetVerificationCodeRequestTests: XCTestCase {
    
    func test_createRequest_shouldSetRequestURL() throws {
        
        let request = try createRequest()
        
        XCTAssertNoDiff(
            request.url?.absoluteString,
            "https://pl.forabank.ru/dbo/api/v3/rest/transfer/v2/getVerificationCode"
        )
    }
    
    func test_createRequest_shouldSetRequestMethodToGet() throws {
        
        let request = try createRequest()
        
        XCTAssertEqual(request.httpMethod, "GET")
    }
    
    func test_createRequest_shouldNotSetRequestBody() throws {
        
        try XCTAssertNil(createRequest().httpBody)
    }

    // MARK: - Helpers
    
    private func createRequest() throws -> URLRequest {
        
        try ForaBank.RequestFactory.createGetVerificationCodeRequest()
    }
}
