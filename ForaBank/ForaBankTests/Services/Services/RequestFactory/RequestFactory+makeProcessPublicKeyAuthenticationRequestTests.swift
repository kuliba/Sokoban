//
//  RequestFactory+makeProcessPublicKeyAuthenticationRequestTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 11.10.2023.
//

@testable import ForaBank
import XCTest
import URLRequestFactory

final class RequestFactory_makeProcessPublicKeyAuthenticationRequestTests: XCTestCase {
    
    func test_makeRequest_shouldThrowOnEmptyDat() throws {
        
        try XCTAssertThrowsAsNSError(
            makeRequest(data: .init()),
            error: URLRequestFactory.Service.Error.emptyData
        )
    }
    
    func test_makeRequest_shouldSetRequestURL() throws {
        
        let request = try makeRequest()
        
        XCTAssertEqual(
            request.url?.absoluteString,
            "https://dmz-api-gate-test.\(Config.domen)/processing/authenticate/v1/processPublicKeyAuthenticationRequest"
        )
    }
    
    func test_makeRequest_shouldSetRequestMethodToPost() throws {
        
        let request = try makeRequest()
        
        XCTAssertEqual(request.httpMethod, "POST")
    }
    
    func test_makeRequest_shouldSetRequestBody() throws {
        
        let data = anyData()
        let request = try makeRequest(data: data)
        
        let httpBody = try XCTUnwrap(request.httpBody)
        XCTAssertNoDiff(httpBody, data)
    }
    
    // MARK: - Helpers
    
    private func makeRequest(
        data: Data = anyData()
    ) throws -> URLRequest {
        
        try RequestFactory.makeProcessPublicKeyAuthenticationRequest(
            data: data
        )
    }
}
