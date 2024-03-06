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
    
    func test_createRequestAccountId_shouldSetHTTPBody() throws {
        
        let payload = anyPayload(.accountId(1))
        let request = try createRequest(payload: payload)
     
        let body = try request.decodedBody(as: Body.self)
        
        XCTAssertNoDiff(body.accountId, payload.productId.value)
        XCTAssertNil(body.cardId)
        XCTAssertNil(body.depositId)
    }
    
    func test_createRequestCardId_shouldSetHTTPBody() throws {
        
        let payload = anyPayload(.cardId(2))
        let request = try createRequest(payload: payload)
     
        let body = try request.decodedBody(as: Body.self)
        
        XCTAssertNoDiff(body.cardId, payload.productId.value)
        XCTAssertNil(body.accountId)
        XCTAssertNil(body.depositId)
    }

    func test_createRequestDepositId_shouldSetHTTPBody() throws {
        
        let payload = anyPayload(.depositId(3))
        let request = try createRequest(payload: payload)
     
        let body = try request.decodedBody(as: Body.self)
        
        XCTAssertNoDiff(body.depositId, payload.productId.value)
        XCTAssertNil(body.accountId)
        XCTAssertNil(body.cardId)
    }

    func test_createRequestAccountId_shouldSetHTTPBody_JSON() throws {
        
        let request = try createRequest(payload: .init(productId: .accountId(1)))
        
        try assertBody(of: request, hasJSON: """
        {
            "accountId": \(1)
        }
        """
        )
    }
    
    func test_createRequestCardId_shouldSetHTTPBody_JSON() throws {
        
        let request = try createRequest(payload: .init(productId: .cardId(2)))
        
        try assertBody(of: request, hasJSON: """
        {
            "cardId": \(2)
        }
        """
        )
    }

    func test_createRequestDepositId_shouldSetHTTPBody_JSON() throws {
        
        let request = try createRequest(payload: .init(productId: .depositId(3)))
        
        try assertBody(of: request, hasJSON: """
        {
            "depositId": \(3)
        }
        """
        )
    }
    
    // MARK: - Helpers
    
    private func createRequest(
        url: URL = anyURL(),
        payload: ProductDetailsPayload = .init(productId: .accountId(1))
    ) throws -> URLRequest {
        
        return try RequestFactory.getProductDetailsRequest(
            url: url,
            payload: payload
        )
    }
    
    private func anyPayload(
        _ productId: ProductDetailsPayload.ProductId
    ) -> ProductDetailsPayload {
        
        .init(productId: productId)
    }
    
    private struct Body: Decodable {
        
        let accountId: Int?
        let cardId: Int?
        let depositId: Int?
    }
}

private extension ProductDetailsPayload.ProductId {
    
    var value: Int {
        
        switch self {
        case let .accountId(accountId):
            return accountId.rawValue
        case let .cardId(cardId):
            return cardId.rawValue
        case let .depositId(depositId):
            return depositId.rawValue
        }
    }

}
