//
//  Services_EndpointGetPINConfirmationCodeTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 11.10.2023.
//

@testable import Vortex
import XCTest

final class Services_EndpointGetPINConfirmationCodeTests: XCTestCase {
    
    func test_urlWithBase_shouldThrowOnEmptyBase() throws {
        
        let endpoint: Services.Endpoint = .getPINConfirmationCode
        let emptyBase = ""
        
        XCTAssertThrowsError(
            try endpoint.url(withBase: emptyBase)
        )
    }
    
    func test_urlWithBase_shouldThrowOnIllegalBase() throws {
        
        let endpoint: Services.Endpoint = .getPINConfirmationCode
        let illegalBase = badURLString
        
        XCTAssertThrowsError(
            try endpoint.url(withBase: illegalBase)
        )
    }
    
    func test_urlWithBase_shouldReturnURL_getPINConfirmationCode() throws {
        
        let endpoint: Services.Endpoint = .getPINConfirmationCode
        
        let url = try endpoint.url(withBase: "any.url")
        
        XCTAssertNoDiff(
            url.absoluteString,
            "//any.url/processing/cardInfo/v1/getPINConfirmationCode"
        )
    }
    
    func test_urlWithBase_shouldThrowOnIllegalBaseURL() throws {
        
        let endpoint: Services.Endpoint = .getPINConfirmationCode
        let illegalBaseURL = URL(staticString: "/")
        
        XCTAssertThrowsError(
            try endpoint.url(withBaseURL: illegalBaseURL)
        )
    }
    
    func test_urlWithBaseURL_shouldReturnURL_getPINConfirmationCode() throws {
        
        let endpoint: Services.Endpoint = .getPINConfirmationCode
        
        let url = try endpoint.url(withBaseURL: baseURL())
        
        XCTAssertNoDiff(
            url.absoluteString,
            "https://pl.innovation.ru/dbo/api/v3/processing/cardInfo/v1/getPINConfirmationCode"
        )
    }
    
    // MARK: - Helpers
    
    private func baseURL() -> URL {
        
        .init(staticString: "https://pl.innovation.ru/dbo/api/v3")
    }
}
