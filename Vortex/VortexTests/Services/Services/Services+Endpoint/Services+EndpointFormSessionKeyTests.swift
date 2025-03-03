//
//  Services+EndpointFormSessionKeyTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 01.08.2023.
//

@testable import Vortex
import XCTest

final class Services_EndpointFormSessionKeyTests: XCTestCase {
    
    func test_urlWithBase_shouldThrowOnEmptyBase() throws {
        
        let endpoint: Services.Endpoint = .formSessionKey
        let emptyBase = ""
        
        XCTAssertThrowsError(
            try endpoint.url(withBase: emptyBase)
        )
    }
    
    func test_urlWithBase_shouldThrowOnIllegalBase() throws {
        
        let endpoint: Services.Endpoint = .formSessionKey
        let illegalBase = badURLString
        
        XCTAssertThrowsError(
            try endpoint.url(withBase: illegalBase)
        )
    }
    
    func test_urlWithBase_shouldReturnURL_formSessionKey() throws {
        
        let endpoint: Services.Endpoint = .formSessionKey
        
        let url = try endpoint.url(withBase: "any.url")
        
        XCTAssertNoDiff(
            url.absoluteString,
            "//any.url/processing/registration/v1/formSessionKey"
        )
    }
    
    func test_urlWithBase_shouldThrowOnIllegalBaseURL() throws {
        
        let endpoint: Services.Endpoint = .formSessionKey
        let illegalBaseURL = URL(staticString: "/")
        
        XCTAssertThrowsError(
            try endpoint.url(withBaseURL: illegalBaseURL)
        )
    }
    
    func test_urlWithBaseURL_shouldReturnURL_formSessionKey() throws {
        
        let endpoint: Services.Endpoint = .formSessionKey
        
        let url = try endpoint.url(withBaseURL: baseURL())
        
        XCTAssertNoDiff(
            url.absoluteString,
            "https://pl.innovation.ru/dbo/api/v3/processing/registration/v1/formSessionKey"
        )
    }
    
    // MARK: - Helpers
    
    private func baseURL() -> URL {
        
        .init(staticString: "https://pl.innovation.ru/dbo/api/v3")
    }
}
