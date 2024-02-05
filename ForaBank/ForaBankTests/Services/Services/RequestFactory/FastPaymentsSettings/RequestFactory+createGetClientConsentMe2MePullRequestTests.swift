//
//  RequestFactory+createGetClientConsentMe2MePullRequestTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 02.02.2024.
//

@testable import ForaBank
import XCTest

final class RequestFactory_createGetClientConsentMe2MePullRequestTests: XCTestCase {
    
    func test_createGetClientConsentMe2MePullRequest_shouldSetRequestURL() {
        
        let request = createGetClientConsentMe2MePullRequest()
        
        XCTAssertNoDiff(
            request.url?.absoluteString,
            "https://pl.forabank.ru/dbo/api/v3/rest/getClientConsentMe2MePull"
        )
    }
    
    func test_createGetClientConsentMe2MePullRequest_shouldSetRequestMethodToGet() {
        
        let request = createGetClientConsentMe2MePullRequest()
        
        XCTAssertEqual(request.httpMethod, "GET")
    }
    
    func test_createGetClientConsentMe2MePullRequest_shouldSetRequestBodyToNil() {
        
        let request = createGetClientConsentMe2MePullRequest()
        
        XCTAssertNil(request.httpBody)
    }
    
    // MARK: - Helpers
    
    private func createGetClientConsentMe2MePullRequest(
    ) -> URLRequest {
        
        RequestFactory.createGetClientConsentMe2MePullRequest()
    }
}
