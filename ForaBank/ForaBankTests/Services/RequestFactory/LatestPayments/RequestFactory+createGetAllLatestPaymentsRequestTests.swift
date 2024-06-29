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
        
        let request = createRequest()
        
        XCTAssertNoDiff(
            request.url?.absoluteString,
            "https://pl.forabank.ru/dbo/api/v3/rest/v2/getAllLatestPayments?isServicePayments=true"
        )
    }
    
    func test_createRequest_shouldSetHTTPMethodToGET() throws {
        
        XCTAssertNoDiff(createRequest().httpMethod, "GET")
    }
    
    func test_createRequest_shouldSetCachePolicy() throws {
        
        XCTAssertNoDiff(createRequest().cachePolicy, .reloadIgnoringLocalAndRemoteCacheData)
    }
    
    func test_createRequest_shouldNotSetHTTPBody() throws {
        
        XCTAssertNil(createRequest().httpBody)
    }
    
    // MARK: - Helpers
    
    private func createRequest() -> URLRequest {
        
        RequestFactory.getAllLatestPaymentsRequest(.service)
    }
}
