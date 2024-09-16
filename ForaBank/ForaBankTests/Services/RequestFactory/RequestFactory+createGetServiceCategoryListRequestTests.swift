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
    
    func test_createRequest_shouldSetRequestURLWithoutSerialOnNilSerial() throws {
        
        try XCTAssertNoDiff(
            createRequest(serial: nil).url?.absoluteString,
            "https://pl.forabank.ru/dbo/api/v3/dict/getServiceCategoryList"
        )
    }
    
    func test_createRequest_shouldSetRequestURLWithoutSerialOnEmptySerial() throws {
        
        try XCTAssertNoDiff(
            createRequest(serial: "").url?.absoluteString,
            "https://pl.forabank.ru/dbo/api/v3/dict/getServiceCategoryList"
        )
    }
    
    func test_createRequest_shouldSetRequestURLWithSerial() throws {
        
        let serial = anyMessage()
        
        try XCTAssertNoDiff(
            createRequest(serial: serial).url?.absoluteString,
            "https://pl.forabank.ru/dbo/api/v3/dict/getServiceCategoryList?serial=\(serial)"
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
    
    private func createRequest(
        serial: String? = nil
    ) throws -> URLRequest {
        
        try RequestFactory.createGetServiceCategoryListRequest(serial: serial)
    }
}
