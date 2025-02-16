//
//  RequestFactory+createCreateC2GPaymentRequestTests.swift
//
//
//  Created by Igor Malyarov on 16.02.2025.
//

import C2GBackend
import RemoteServices
import XCTest

final class RequestFactory_createCreateC2GPaymentRequestTests: XCTestCase {
    
    func test_createRequest_shouldSetURL() throws {
        
        let url = anyURL()
        let request = try createRequest(url)
        
        XCTAssertNoDiff(request.url, url)
    }
    
    func test_createRequest_shouldThrowOnEmptyUIN() throws {
        
        let emptyUINPayload = makePayload(uin: "")
        
        XCTAssertThrowsError(try createRequest(payload: emptyUINPayload)) {
            
            XCTAssert($0 is RequestFactory.EmptyUIN)
        }
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
        
        let payload = makePayload()
        let request = try createRequest(payload: payload)
        
        let body = try request.decodedBody(as: Body.self)
        XCTAssertNoDiff(body.UIN, payload.uin)
    }
    
    func test_createRequest_shouldThrow_onMissingValues() throws {
        
        let payload = makePayload(accountID: nil, cardID: nil, uin: "testUIN")
        
        XCTAssertThrowsError(try createRequest(payload: payload)) {
            
            XCTAssert($0 is RequestFactory.CreateC2GPaymentPayload.MissingPaymentIdentifiers)
        }
    }
    
    func test_createRequest_shouldSetHTTPBodyWithUINAndAccountID_onAccountIDOnly() throws {
        
        let payload = makePayload(accountID: 123, cardID: nil, uin: "testUIN")
        let request = try createRequest(payload: payload)
        
        let body = try request.decodedBody(as: Body.self)
        XCTAssertEqual(body.UIN, "testUIN")
        XCTAssertEqual(body.accountId, 123)
        XCTAssertNil(body.cardId)
    }
    
    func test_createRequest_shouldSetHTTPBodyWithUINAndCardID_onCardIDOnly() throws {
        
        let payload = makePayload(accountID: nil, cardID: 456, uin: "testUIN")
        let request = try createRequest(payload: payload)
        
        let body = try request.decodedBody(as: Body.self)
        XCTAssertEqual(body.UIN, "testUIN")
        XCTAssertNil(body.accountId)
        XCTAssertEqual(body.cardId, 456)
    }
    
    func test_createRequest_shouldSetHTTPBodyWithUINAndAccountID_onBothAccountIDAndCardIDProvided() throws {
        
        let payload = makePayload(accountID: 123, cardID: 456, uin: "testUIN")
        let request = try createRequest(payload: payload)
        
        let body = try request.decodedBody(as: Body.self)
        XCTAssertEqual(body.UIN, "testUIN")
        XCTAssertEqual(body.accountId, 123)
        XCTAssertNil(body.cardId)
    }
    
    func test_createRequest_shouldSetHTTPBodyWithAccountID_JSON() throws {
        
        let payload = makePayload(accountID: 123, cardID: nil)
        let request = try createRequest(payload: payload)
        
        try assertBody(of: request, hasJSON: """
        { "accountId": 123, "UIN": "\(payload.uin)" }
        """
        )
    }
    
    func test_createRequest_shouldSetHTTPBodyWithCardID_JSON() throws {
        
        let payload = makePayload(accountID: nil, cardID: 456)
        let request = try createRequest(payload: payload)
        
        try assertBody(of: request, hasJSON: """
        { "cardId": 456, "UIN": "\(payload.uin)" }
        """
        )
    }
    
    // MARK: - Helpers
    
    private typealias Payload = RequestFactory.CreateC2GPaymentPayload
    
    private func createRequest(
        _ url: URL = anyURL(),
        payload: Payload? = nil
    ) throws -> URLRequest {
        
        try RequestFactory.createCreateC2GPaymentRequest(
            url: url,
            payload: payload ?? makePayload()
        )
    }
    
    private func makePayload(
        accountID: Int? = nil,
        cardID: Int? = .random(in: 1...100),
        uin: String = anyMessage()
    ) -> Payload {
        
        return .init(accountID: accountID, cardID: cardID, uin: uin)
    }
    
    private struct Body: Decodable {
        
        let accountId: Int?
        let cardId: Int?
        let UIN: String
    }
}
