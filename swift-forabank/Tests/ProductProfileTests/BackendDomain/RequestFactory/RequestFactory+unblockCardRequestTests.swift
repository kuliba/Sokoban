//
//  RequestFactory+unblockCardRequestTests.swift
//
//
//  Created by Andryusina Nataly on 12.02.2024.
//

import ProductProfile
import XCTest
import Services

final class RequestFactory_unblockCardRequestTests: XCTestCase {
    
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
        
        XCTAssertNoDiff(body.cardID, payload.cardId.rawValue)
        XCTAssertNoDiff(body.cardNumber, payload.cardNumber?.rawValue)
    }
    
    func test_createRequest_shouldSetHTTPBody_JSON() throws {
        
        let cardId = 1111
        let cardNumber = "2222"
        let request = try createRequest(payload: .init(cardId: .init(cardId), cardNumber: .init(cardNumber)))
        
        try assertBody(of: request, hasJSON: """
        {
            "cardNumber": "\(cardNumber)",
            "cardID": \(Int(cardId))
        }
        """
        )
    }
    
    // MARK: - Helpers
    
    private func createRequest(
        url: URL = anyURL(),
        payload: Payload.CardPayload = .init(cardId: 1, cardNumber: "11")
    ) throws -> URLRequest {
        
        return try RequestFactory.unblockCardRequest(
            url: url,
            payload: payload
        )
    }
    
    private func anyPayload(
       _ cardID: Payload.CardPayload.CardID = 1,
       _ cardNumber: Payload.CardPayload.CardNumber = "11"
    ) -> Payload.CardPayload {
        
        .init(cardId: cardID, cardNumber: cardNumber)
    }
    
    private struct Body: Decodable {
        
        let cardID: Int
        let cardNumber: String?
    }
}
