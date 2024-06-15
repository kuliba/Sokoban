//
//  RequestFactory+createChangeSVCardLimitRequest.swift
//
//
//  Created by Andryusina Nataly on 14.06.2024.
//

import ChangeSVCardLimitAPI
import RemoteServices
import XCTest

final class RequestFactory_createChangeSVCardLimitRequestTests: XCTestCase {
    
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
        XCTAssertNoDiff(body.cardId, payload.cardId)
        XCTAssertNoDiff(body.limit.name, payload.limit.name)
        XCTAssertNoDiff(body.limit.value, payload.limit.value)
    }
    
    func test_createRequest_shouldSetHTTPBody_JSON() throws {
        
        let cardId = 123456789
        let name = "name"
        let value: Decimal = 10.01
        let request = try createRequest(
            payload: .init(
                cardId: cardId,
                limit: .init(name: name, value: value)))
        
        try assertBody(of: request, hasJSON: """
        {
            "cardId": "\(cardId)",
            "limit": {
                "name": "\(name)",
                "value": "\(value)"
            }
        }
        """
        )
    }
    
    // MARK: - Helpers
    
    private func createRequest(
        url: URL = anyURL(),
        payload: ChangeSVCardLimitPayload = .init(cardId: 111, limit: .init(name: "limit", value: 10.01))
    ) throws -> URLRequest {
        
        try RequestFactory.createChangeSVCardLimitRequest(
            url: url,
            payload: payload
        )
    }
    
    private func anyPayload(
        cardId: Int = 111,
        limitName: String = "name",
        value: Decimal = 10.01
    ) -> ChangeSVCardLimitPayload {
        
        .init(
            cardId: cardId,
            limit: .init(name: limitName, value: value)
        )
    }
    
    private struct Body: Decodable {
        
        let cardId: Int
        let limit: Limit
        
        struct Limit: Decodable {
            let name: String
            let value: Decimal
        }
    }
}
