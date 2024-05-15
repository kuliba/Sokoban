//
//  RequestFactory+createGetAllLatestPaymentsRequestTests.swift
//  ForaBankTests
//
//  Created by Дмитрий Савушкин on 13.05.2024.
//

@testable import ForaBank
import RemoteServices
import XCTest

final class RequestFactory_createGetAllLatestPaymentsRequestTests: XCTestCase {
    
    func test_createRequest_shouldSetRequestURL() throws {
        
        let request = try createRequest()

        XCTAssertNoDiff(
            request.url?.absoluteString,
            "https://pl.forabank.ru/dbo/api/v3/rest/v2/getAllLatestPayments?isServicePayments=true"
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
    
    private func createRequest() throws -> URLRequest {
        
        try RequestFactory.getAllLatestPaymentsRequest(.service)
    }

}
