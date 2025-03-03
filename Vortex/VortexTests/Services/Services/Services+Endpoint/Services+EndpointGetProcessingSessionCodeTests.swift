//
//  Services+EndpointGetProcessingSessionCodeTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 31.07.2023.
//

@testable import Vortex
import XCTest

final class Services_EndpointGetProcessingSessionCodeTests: XCTestCase {
    
    func test_urlWithBase_shouldThrowOnEmptyBase() throws {
        
        let endpoint: Services.Endpoint = .getProcessingSessionCode
        let emptyBase = ""
        
        XCTAssertThrowsError(
            try endpoint.url(withBase: emptyBase)
        )
    }
    
    func test_urlWithBase_shouldThrowOnIllegalBase() throws {
        
        let endpoint: Services.Endpoint = .getProcessingSessionCode
        let illegalBase = badURLString
        
        XCTAssertThrowsError(
            try endpoint.url(withBase: illegalBase)
        )
    }
    
    func test_urlWithBase_shouldReturnURL_getProcessingSessionCode() throws {
        
        let endpoint: Services.Endpoint = .getProcessingSessionCode
        
        let url = try endpoint.url(withBase: "any.url")
        
        XCTAssertNoDiff(
            url.absoluteString,
            "//any.url/processing/registration/v1/getProcessingSessionCode"
        )
    }
    
    func test_urlWithBase_shouldThrowOnIllegalBaseURL() throws {
        
        let endpoint: Services.Endpoint = .getProcessingSessionCode
        let illegalBaseURL = URL(staticString: "/")
        
        XCTAssertThrowsError(
            try endpoint.url(withBaseURL: illegalBaseURL)
        )
    }
    
    func test_urlWithBaseURL_shouldReturnURL_getProcessingSessionCode() throws {
        
        let endpoint: Services.Endpoint = .getProcessingSessionCode
        
        let url = try endpoint.url(withBaseURL: baseURL())
        
        XCTAssertNoDiff(
            url.absoluteString,
            "https://pl.innovation.ru/dbo/api/v3/processing/registration/v1/getProcessingSessionCode"
        )
    }
    
    // MARK: - Helpers
    
    private func baseURL() -> URL {
        
        .init(staticString: "https://pl.innovation.ru/dbo/api/v3")
    }
}
