//
//  RequestFactory+getProductDetailsRequestTests.swift
//
//
//  Created by Andryusina Nataly on 05.03.2024.
//

@testable import AccountInfoPanel
import XCTest
import Services

final class RequestFactory_getProductDetailsRequestTests: XCTestCase {
    
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
        
        let payload = anyPayload()
        let request = try createRequest(payload: payload)
     
        let body = try request.decodedBody(as: Body.self)
        
        XCTAssertNoDiff(body.accountId, payload.accountId?.rawValue)
        XCTAssertNoDiff(body.cardId, payload.cardId?.rawValue)
        XCTAssertNoDiff(body.depositId, payload.depositId?.rawValue)
    }
    
    func test_createRequest_shouldSetHTTPBody_JSON() throws {
        
        let accountId = 1111
        let cardId = 2222
        let depositId = 3333

        let request = try createRequest(payload: .init(
            accountId: .init(accountId),
            cardId: .init(cardId),
            depositId: .init(depositId)))
        
        try assertBody(of: request, hasJSON: """
        {
            "accountId": \(Int(accountId)),
            "cardId": \(Int(cardId)),
            "depositId": \(Int(depositId))
        }
        """
        )
    }
    
    // MARK: - Helpers
    
    private func createRequest(
        url: URL = anyURL(),
        payload: ProductDetailsPayload = .init(
            accountId: 1,
            cardId: 2,
            depositId: 3)
    ) throws -> URLRequest {
        
        return try RequestFactory.getProductDetailsRequest(
            url: url,
            payload: payload
        )
    }
    
    private func anyPayload(
        _ accountId: ProductDetailsPayload.AccountId? = 1,
        _ cardId: ProductDetailsPayload.CardId? = 2,
        _ depositId: ProductDetailsPayload.DepositId? = 3
    ) -> ProductDetailsPayload {
        
        .init(
            accountId: accountId,
            cardId: cardId,
            depositId: depositId
        )
    }
    
    private struct Body: Decodable {
        
        let accountId: Int?
        let cardId: Int?
        let depositId: Int?
    }
}
