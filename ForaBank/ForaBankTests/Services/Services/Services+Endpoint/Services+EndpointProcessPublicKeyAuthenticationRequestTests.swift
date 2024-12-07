//
//  Services+EndpointProcessPublicKeyAuthenticationRequestTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 11.10.2023.
//

@testable import ForaBank
import XCTest

final class Services_EndpointProcessPublicKeyAuthenticationRequestTests: XCTestCase {
    
    func test_urlWithBase_shouldThrowOnEmptyBase() throws {
        
        let endpoint: Services.Endpoint = .processPublicKeyAuthenticationRequest
        let emptyBase = ""
        
        XCTAssertThrowsError(
            try endpoint.url(withBase: emptyBase)
        )
    }
    
    func test_urlWithBase_shouldThrowOnIllegalBase() throws {
        
        let endpoint: Services.Endpoint = .processPublicKeyAuthenticationRequest
        let illegalBase = "🤯"
        
        XCTAssertThrowsError(
            try endpoint.url(withBase: illegalBase)
        )
    }
    
    func test_urlWithBase_shouldReturnURL_processPublicKeyAuthenticationRequest() throws {
        
        let endpoint: Services.Endpoint = .processPublicKeyAuthenticationRequest
        
        let url = try endpoint.url(withBase: "any.url")
        
        XCTAssertNoDiff(
            url.absoluteString,
            "//any.url/processing/authenticate/v1/processPublicKeyAuthenticationRequest"
        )
    }
    
    func test_urlWithBase_shouldThrowOnIllegalBaseURL() throws {
        
        let endpoint: Services.Endpoint = .processPublicKeyAuthenticationRequest
        let illegalBaseURL = URL(staticString: "/")
        
        XCTAssertThrowsError(
            try endpoint.url(withBaseURL: illegalBaseURL)
        )
    }
    
    func test_urlWithBaseURL_shouldReturnURL_processPublicKeyAuthenticationRequest() throws {
        
        let endpoint: Services.Endpoint = .processPublicKeyAuthenticationRequest
        
        let url = try endpoint.url(withBaseURL: baseURL())
        
        XCTAssertNoDiff(
            url.absoluteString,
            "https://pl.innovation.ru/dbo/api/v3/processing/authenticate/v1/processPublicKeyAuthenticationRequest"
        )
    }
    
    // MARK: - Helpers
    
    private func baseURL() -> URL {
        
        .init(staticString: "https://pl.innovation.ru/dbo/api/v3")
    }
}
