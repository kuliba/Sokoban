//
//  RequestFactory+createMakeOpenSavingsAccountRequestTests.swift
//  VortexTests
//
//  Created by Andryusina Nataly on 21.02.2025.
//

import XCTest
@testable import Vortex

final class RequestFactory_createMakeOpenSavingsAccountRequestTests: XCTestCase {
    
    func test_createRequest_shouldSetRequestURL() throws {
        
        let request = try createRequest()
        
        XCTAssertEqual(
            request.url?.absoluteString,
            "https://pl.\(Config.domen)/dbo/api/v3/rest/makeOpenSavingsAccount"
        )
    }
    
    func test_createRequest_shouldSetRequestMethodToPost() throws {
        
        let request = try createRequest()
        
        XCTAssertEqual(request.httpMethod, "POST")
    }
    
    func test_createRequest_shouldSetRequestBodyToNil() throws {
        
        let payload: MakeOpenSavingsAccountPayload = createPayloadWithRandomValue()
        
        let request = try createRequest(payload: payload)
        
        let decodedRequest = try JSONDecoder().decode(
            Payload.self,
            from: XCTUnwrap(request.httpBody)
        )
        
        XCTAssertNoDiff(decodedRequest.sourceAccountId, payload.accountID)
        XCTAssertNoDiff(decodedRequest.amount, payload.amount)
        XCTAssertNoDiff(decodedRequest.sourceCardId, payload.cardID)
        XCTAssertNoDiff(decodedRequest.cryptoVersion, payload.cryptoVersion)
        XCTAssertNoDiff(decodedRequest.currencyCode, payload.currencyCode)
        XCTAssertNoDiff(decodedRequest.verificationCode, payload.verificationCode)
    }
    
    // MARK: - Helpers
    
    private func createRequest(
        payload: MakeOpenSavingsAccountPayload = .default
    ) throws -> URLRequest {
        
        try Vortex.RequestFactory.createMakeOpenSavingsAccountRequest(payload: payload)
    }
    
    private func createPayloadWithRandomValue(
    ) -> MakeOpenSavingsAccountPayload {
        
        .init(accountID: .random(in: (0...Int.max)), amount: 11, cardID: .random(in: (0...Int.max)), cryptoVersion: anyMessage(), currencyCode: Int.random(in: (0...Int.max)), verificationCode: anyMessage())
    }
}

private extension MakeOpenSavingsAccountPayload {
    
    static let `default`: Self = .init(accountID: 1, amount: 2, cardID: 3, cryptoVersion: "1", currencyCode: 4, verificationCode: "5")
}

private struct Payload: Decodable {
    
    let sourceAccountId: Int?
    let amount: Decimal?
    let sourceCardId: Int?
    let cryptoVersion: String
    let currencyCode: Int?
    let verificationCode: String
}
