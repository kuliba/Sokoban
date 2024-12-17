//
//  RequestFactory+makeGetPINConfirmationCodeRequestTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 11.10.2023.
//

@testable import ForaBank
import XCTest
import URLRequestFactory

final class RequestFactory_makeGetPINConfirmationCodeRequestTests: XCTestCase {
    
    func test_makeRequest_shouldThrowOnEmptySessionID() throws {
        
        try XCTAssertThrowsAsNSError(
            makeRequest(with: makeSessionID("")),
            error: URLRequestFactory.Service.Error.emptySessionID
        )
    }
    
    func test_makeRequest_shouldSetRequestURL() throws {
        
        let sessionID = makeSessionID()
        let request = try makeRequest(with: sessionID)
        
        XCTAssertNoDiff(
            request.url?.absoluteString,
            "https://dmz-api-gate-test.forabank.ru/processing/cardInfo/v1/getPINConfirmationCode?sessionId=\(sessionID.sessionIDValue)"
        )
    }
    
    func test_makeRequest_shouldSetRequestMethodToGet() throws {
        
        let request = try makeRequest()
        
        XCTAssertEqual(request.httpMethod, "GET")
    }
    
    func test_makeRequest_shouldSetRequestBodyToEmpty() throws {
        
        let request = try makeRequest()
        
        XCTAssertNil(request.httpBody)
    }
    
    // MARK: - Helpers
    
    private func makeRequest(
        with sessionID: ForaBank.SessionID = makeSessionID()
    ) throws -> URLRequest {
        
        let request = try RequestFactory.makeGetPINConfirmationCodeRequest(sessionID: sessionID)
        
        return request
    }
}
