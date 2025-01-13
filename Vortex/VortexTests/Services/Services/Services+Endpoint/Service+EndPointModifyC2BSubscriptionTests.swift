//
//  Service+EndPointModifyC2BSubscriptionTests.swift
//  ForaBankTests
//
//  Created by Дмитрий Савушкин on 08.11.2024.
//

@testable import ForaBank
import XCTest

final class Service_EndPointModifyC2BSubscriptionTests: XCTestCase {
    
    func test_urlWithBaseAcc_shouldThrowOnEmptyBase() throws {
        
        let endpoint: Services.Endpoint = .modifyC2BSubAccData
        let emptyBase = ""
        
        XCTAssertThrowsError(
            try endpoint.url(withBase: emptyBase)
        )
    }
    
    func test_urlWithBaseCard_shouldThrowOnEmptyBase() throws {
        
        let endpoint: Services.Endpoint = .modifyC2BSubCardData
        let emptyBase = ""
        
        XCTAssertThrowsError(
            try endpoint.url(withBase: emptyBase)
        )
    }
    
    func test_urlWithBaseAcc_shouldThrowOnIllegalBase() throws {
        
        let endpoint: Services.Endpoint = .modifyC2BSubAccData
        let illegalBase = "🤯"
        
        XCTAssertThrowsError(
            try endpoint.url(withBase: illegalBase)
        )
    }
    
    func test_urlWithBaseCard_shouldThrowOnIllegalBase() throws {
        
        let endpoint: Services.Endpoint = .modifyC2BSubCardData
        let illegalBase = "🤯"
        
        XCTAssertThrowsError(
            try endpoint.url(withBase: illegalBase)
        )
    }
    
    func test_urlWithBase_shouldReturnURL_bindPublicKeyWithEventId() throws {
        
        let endpoint: Services.Endpoint = .modifyC2BSubAccData
        
        let url = try endpoint.url(withBase: "any.url")
        
        XCTAssertNoDiff(
            url.absoluteString,
            "//any.url/rest/binding/v1/modifyC2BSubAcc"
        )
    }
    
    func test_urlWithBaseCard_shouldReturnURL_bindPublicKeyWithEventId() throws {
        
        let endpoint: Services.Endpoint = .modifyC2BSubCardData
        
        let url = try endpoint.url(withBase: "any.url")
        
        XCTAssertNoDiff(
            url.absoluteString,
            "//any.url/rest/binding/v1/modifyC2BSubCard"
        )
    }

    func test_urlWithBaseAcc_shouldThrowOnIllegalBaseURL() throws {
        
        let endpoint: Services.Endpoint = .modifyC2BSubAccData
        let illegalBaseURL = URL(staticString: "/")
        
        XCTAssertThrowsError(
            try endpoint.url(withBaseURL: illegalBaseURL)
        )
    }
    
    func test_urlWithBaseCard_shouldThrowOnIllegalBaseURL() throws {
        
        let endpoint: Services.Endpoint = .modifyC2BSubCardData
        let illegalBaseURL = URL(staticString: "/")
        
        XCTAssertThrowsError(
            try endpoint.url(withBaseURL: illegalBaseURL)
        )
    }
    
    func test_urlWithBaseURLAcc_shouldReturnURL_bindPublicKeyWithEventID() throws {
        
        let endpoint: Services.Endpoint = .modifyC2BSubAccData
        
        let url = try endpoint.url(withBaseURL: baseURL())
        
        XCTAssertNoDiff(
            url.absoluteString,
            "https://pl.forabank.ru/dbo/api/v3/rest/binding/v1/modifyC2BSubAcc"
        )
    }
    
    func test_urlWithBaseURLCard_shouldReturnURL_bindPublicKeyWithEventID() throws {
        
        let endpoint: Services.Endpoint = .modifyC2BSubCardData
        
        let url = try endpoint.url(withBaseURL: baseURL())
        
        XCTAssertNoDiff(
            url.absoluteString,
            "https://pl.forabank.ru/dbo/api/v3/rest/binding/v1/modifyC2BSubCard"
        )
    }
    
    // MARK: - Helpers
    
    private func baseURL() -> URL {
        
        .init(staticString: "https://pl.forabank.ru/dbo/api/v3")
    }
}
