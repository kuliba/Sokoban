//
//  RequestFactory+createMakeOpenSavingsAccountRequestTests.swift
//
//
//  Created by Andryusina Nataly on 25.11.2024.
//

import SavingsServices
import RemoteServices
import XCTest

final class RequestFactory_createMakeOpenSavingsAccountRequestTests: XCTestCase {
    
    func test_createRequest_shouldSetURL() throws {
        
        let url = anyURL()
        let request = try createRequest(url: url)
        
        XCTAssertNoDiff(request.url, url)
    }
    
    func test_createRequest_shouldSetHTTPMethodToPOST() throws {
        
        let request = try createRequest()
        
        XCTAssertNoDiff(request.httpMethod, "POST")
    }
    
    func test_createRequest_shouldSetCachePolicy() throws {
        
        let request = try createRequest()
        
        XCTAssertNoDiff(request.cachePolicy, .reloadIgnoringLocalAndRemoteCacheData)
    }
    
    func test_createRequest_shouldSetHTTPBody() throws {
        
        let payload = makePayload(
            accountID: .random(in: 0..<20),
            amount: 200,
            cardID: .random(in: 0..<20),
            cryptoVersion: anyMessage(),
            currencyCode: 10,
            verificationCode: anyMessage()
        )
        let request = try createRequest(payload: payload)
        let body = try request.decodedBody(as: _DTO.self)
        
        XCTAssertEqual(body, _DTO(payload))
    }
        
    // MARK: - Helpers
    
    private func createRequest(
        url: URL = anyURL(),
        payload: MakeOpenSavingsAccountPayload = makePayload()
    ) throws -> URLRequest {
        
        try RequestFactory.createMakeOpenSavingsAccountRequest(
            payload: payload,
            url: url
        )
    }
}

private struct _DTO: Decodable, Equatable {
    
    let amount: Double?
    let cryptoVersion: String
    let currencyCode: Int?
    let sourceAccountId: Int?
    let sourceCardId: Int?
    let verificationCode: String
}

private extension _DTO {
    
    init(_ payload: MakeOpenSavingsAccountPayload) {
        
        self.init(
            amount:(payload.amount as? NSDecimalNumber)?.doubleValue,
            cryptoVersion: payload.cryptoVersion,
            currencyCode: payload.currencyCode,
            sourceAccountId: payload.accountID,
            sourceCardId: payload.cardID,
            verificationCode: payload.verificationCode)
    }
}

private func makePayload(
    accountID: Int? = nil,
    amount: Decimal? = nil,
    cardID: Int? = nil,
    cryptoVersion: String = "1.0",
    currencyCode: Int? = nil,
    verificationCode: String = "111111"
) -> MakeOpenSavingsAccountPayload {
    
    .init(
        accountID: accountID,
        amount: amount,
        cardID: cardID,
        cryptoVersion: cryptoVersion,
        currencyCode: currencyCode,
        verificationCode: verificationCode
    )
}
