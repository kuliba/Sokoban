//
//  RequestFactory+createGetSVCardLimitRequest.swift
//
//
//  Created by Andryusina Nataly on 18.06.2024.
//

import SVCardLimitAPI
import RemoteServices
import XCTest

final class RequestFactory_createGetSVCardLimitRequestTests: XCTestCase {
    
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
    }
        
    // MARK: - Helpers
    
    private func createRequest(
        url: URL = anyURL(),
        payload: GetSVCardLimitPayload = .init(cardId: 111)
    ) throws -> URLRequest {
        
        try RequestFactory.createGetSVCardLimitRequest(
            url: url,
            payload: payload
        )
    }
    
    private func anyPayload(
        cardId: Int = 111
    ) -> GetSVCardLimitPayload {
        
        .init(cardId: cardId)
    }
    
    private struct Body: Decodable {
        
        let cardId: Int
    }
}
