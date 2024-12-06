//
//  Services_EndpointChangePINTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 11.10.2023.
//

@testable import ForaBank
import XCTest

final class Services_EndpointChangePINTests: XCTestCase {
    
    func test_urlWithBase_shouldThrowOnEmptyBase() throws {
        
        let endpoint: Services.Endpoint = .changePIN
        let emptyBase = ""
        
        XCTAssertThrowsError(
            try endpoint.url(withBase: emptyBase)
        )
    }
    
    
    func test_urlWithBase_shouldThrowOnIllegalBase() throws {
        
        let endpoint: Services.Endpoint = .changePIN
        let illegalBase = "🤯"
        
        XCTAssertThrowsError(
            try endpoint.url(withBase: illegalBase)
        )
    }
    
    func test_urlWithBase_shouldReturnURL_changePIN() throws {
        
        let endpoint: Services.Endpoint = .changePIN
        
        let url = try endpoint.url(withBase: "any.url")
        
        XCTAssertNoDiff(
            url.absoluteString,
            "//any.url/processing/cardInfo/v1/changePIN"
        )
    }
    
    func test_urlWithBase_shouldThrowOnIllegalBaseURL() throws {
        
        let endpoint: Services.Endpoint = .changePIN
        let illegalBaseURL = URL(staticString: "/")
        
        XCTAssertThrowsError(
            try endpoint.url(withBaseURL: illegalBaseURL)
        )
    }
    
    func test_urlWithBaseURL_shouldReturnURL_changePIN() throws {
        
        let endpoint: Services.Endpoint = .changePIN
        
        let url = try endpoint.url(withBaseURL: baseURL())
        
        XCTAssertNoDiff(
            url.absoluteString,
            "https://pl.forabank.ru/dbo/api/v3/processing/cardInfo/v1/changePIN"
        )
    }
    
    // MARK: - Helpers
    
    private func baseURL() -> URL {
        
        .init(staticString: "https://pl.forabank.ru/dbo/api/v3")
    }
}
