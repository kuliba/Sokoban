//
//  RequestFactory+createChangeClientConsentMe2MePullRequestTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 03.02.2024.
//

import FastPaymentsSettings
import RemoteServices
@testable import ForaBank
import XCTest

final class RequestFactory_createChangeClientConsentMe2MePullRequestTests: XCTestCase {
    
    func test_createChangeClientConsentMe2MePullRequest_shouldSetRequestURL() throws {
        
        let request = try createChangeClientConsentMe2MePullRequest()
        
        XCTAssertNoDiff(
            request.url?.absoluteString,
            "https://pl.forabank.ru/dbo/api/v3/rest/changeClientConsentMe2MePull"
        )
    }
    
    func test_createChangeClientConsentMe2MePullRequest_shouldSetRequestMethodToPost() throws {
        
        let request = try createChangeClientConsentMe2MePullRequest()
        
        XCTAssertEqual(request.httpMethod, "POST")
    }
    
    func test_createChangeClientConsentMe2MePullRequest_shouldSetRequestBodyToEmptyListOnEmpty() throws {
        
        let payload = anyPayload(count: 0)
        let request = try createChangeClientConsentMe2MePullRequest(payload)
        
        let decoded = try JSONDecoder().decode(_Payload.self, from: XCTUnwrap(request.httpBody))
        
        XCTAssertNoDiff(decoded.bankIdList, [])
    }
    
    func test_createChangeClientConsentMe2MePullRequest_shouldSetRequestBody() throws {
        
        let payload = anyPayload()
        let request = try createChangeClientConsentMe2MePullRequest(payload)
        
        let decoded = try JSONDecoder().decode(_Payload.self, from: XCTUnwrap(request.httpBody))
        
        XCTAssertNoDiff(decoded.bankIdList, payload.map(\.rawValue))
    }
    
    // MARK: - Helpers
    
    private func createChangeClientConsentMe2MePullRequest(
        _ payload: FastRequestFactory.BankIDList = anyPayload()
    ) throws -> URLRequest {
        
        try RequestFactory.createChangeClientConsentMe2MePullRequest(payload)
    }
    
    private struct _Payload: Decodable, Equatable {
        
        let bankIdList: [String]
    }
}

private typealias FastRequestFactory = RemoteServices.RequestFactory

private func anyPayload(
    count: Int = 2
) -> FastRequestFactory.BankIDList {
    
    (0..<count).map { _ in .init(UUID().uuidString) }
}
