//
//  RequestFactory+createGetServiceCategoryListRequestTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 13.08.2024.
//

@testable import ForaBank
import RemoteServices
import XCTest

final class RequestFactory_createGetServiceCategoryListRequestTests: XCTestCase {
    
    func test_createRequest_shouldSetRequestURL() throws {
        
        try XCTAssertNoDiff(
            createRequest().url?.absoluteString,
            "https://pl.forabank.ru/dbo/api/v3/dict/getServiceCategoryList"
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
        
        try RequestFactory.createGetServiceCategoryListRequest()
    }
}
