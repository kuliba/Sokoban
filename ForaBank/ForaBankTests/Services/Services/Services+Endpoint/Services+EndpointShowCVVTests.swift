//
//  Services+EndpointShowCVVTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 11.10.2023.
//

@testable import ForaBank
import XCTest

final class Services_EndpointShowCVVTests: XCTestCase {
    
    func test_urlWithBase_shouldThrowOnEmptyBase() throws {
        
        let endpoint: Services.Endpoint = .showCVV
        let emptyBase = ""
        
        XCTAssertThrowsError(
            try endpoint.url(withBase: emptyBase)
        )
    }
    
    func test_urlWithBase_shouldThrowOnIllegalBase() throws {
        
        let endpoint: Services.Endpoint = .showCVV
        let illegalBase = "🤯"
        
        XCTAssertThrowsError(
            try endpoint.url(withBase: illegalBase)
        )
    }
    
    func test_urlWithBase_shouldReturnURL_showCVV() throws {
        
        let endpoint: Services.Endpoint = .showCVV
        
        let url = try endpoint.url(withBase: "any.url")
        
        XCTAssertNoDiff(
            url.absoluteString,
            "//any.url/processing/cardInfo/v1/showCVV"
        )
    }
    
    func test_urlWithBase_shouldThrowOnIllegalBaseURL() throws {
        
        let endpoint: Services.Endpoint = .showCVV
        let illegalBaseURL = URL(staticString: "/")
        
        XCTAssertThrowsError(
            try endpoint.url(withBaseURL: illegalBaseURL)
        )
    }
    
    func test_urlWithBaseURL_shouldReturnURL_showCVV() throws {
        
        let endpoint: Services.Endpoint = .showCVV
        
        let url = try endpoint.url(withBaseURL: baseURL())
        
        XCTAssertNoDiff(
            url.absoluteString,
            "https://pl.innovation.ru/dbo/api/v3/processing/cardInfo/v1/showCVV"
        )
    }
    
    // MARK: - Helpers
    
    private func baseURL() -> URL {
        
        .init(staticString: "https://pl.innovation.ru/dbo/api/v3")
    }
}
