//
//  RequestFactory+createMakeSetBankDefaultRequestTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 03.02.2024.
//

import FastPaymentsSettings
import RemoteServices
@testable import ForaBank
import XCTest

final class RequestFactory_createMakeSetBankDefaultRequestTests: XCTestCase {
    
    func test_createGetBankDefaultRequest_shouldThrowOnEmptyVerificationCode() throws {
        
        let emptyCode = ""
        
        try XCTAssertThrowsError( createMakeSetBankDefaultRequest(anyPayload(emptyCode))
        )
    }
    
    func test_createMakeSetBankDefaultRequest_shouldSetRequestURL() throws {
        
        let request = try createMakeSetBankDefaultRequest()
        
        XCTAssertNoDiff(
            request.url?.absoluteString,
            "https://pl.forabank.ru/dbo/api/v3/rest/makeSetBankDefault"
        )
    }
    
    func test_createMakeSetBankDefaultRequest_shouldSetRequestMethodToPost() throws {
        
        let request = try createMakeSetBankDefaultRequest()
        
        XCTAssertEqual(request.httpMethod, "POST")
    }
    
    func test_createMakeSetBankDefaultRequest_shouldSetRequestBody() throws {
        
        let payload = anyPayload()
        let request = try createMakeSetBankDefaultRequest(payload)
        
        let decoded = try JSONDecoder().decode(_Payload.self, from: XCTUnwrap(request.httpBody))
        
        XCTAssertNoDiff(decoded.verificationCode, payload.rawValue)
    }
    
    // MARK: - Helpers
    
    private func createMakeSetBankDefaultRequest(
        _ payload: FastRequestFactory.VerificationCode = anyPayload()
    ) throws -> URLRequest {
        
        try RequestFactory.createMakeSetBankDefaultRequest(payload: payload)
    }
    
    private struct _Payload: Decodable, Equatable {
        
        let verificationCode: String
    }
}

private typealias FastRequestFactory = RemoteServices.RequestFactory

private func anyPayload(
    _ rawValue: String = UUID().uuidString
) -> FastRequestFactory.VerificationCode {
    
    .init(rawValue)
}
