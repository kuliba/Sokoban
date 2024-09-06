//
//  RequestFactory+createGetPaymentTemplateListRequestTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 05.09.2024.
//

@testable import ForaBank
import RemoteServices
import XCTest

final class RequestFactory_createGetPaymentTemplateListRequestTests: XCTestCase {
    
    func test_createRequest_shouldSetRequestURL() throws {
        
        try XCTAssertNoDiff(
            createRequest().url?.absoluteString,
            "https://pl.forabank.ru/dbo/api/v3/rest/v3/getPaymentTemplateList"
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
    
    private func createRequest() throws -> URLRequest {
        
        try ForaBank.RequestFactory.createGetPaymentTemplateListRequestV3()
    }
}
