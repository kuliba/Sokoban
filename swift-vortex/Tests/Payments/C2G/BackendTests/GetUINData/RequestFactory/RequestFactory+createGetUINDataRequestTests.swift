//
//  RequestFactory+createGetUINDataRequestTests.swift
//
//
//  Created by Igor Malyarov on 16.02.2025.
//

import C2GBackend
import RemoteServices
import XCTest

final class RequestFactory_createGetUINDataRequestTests: XCTestCase {
    
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
    
    func test_createRequest_shouldSetHTTPBody_JSON() throws {
        
        let payload = makePayload()
        let request = try createRequest(payload: payload)
        
        try assertBody(of: request, hasJSON: """
        {"UIN": "\(payload.uin)"}
        """
        )
    }
    
    // MARK: - Helpers
    
    private typealias Payload = RequestFactory.GetUINDataPayload
    
    private func createRequest(
        _ url: URL = anyURL(),
        payload: Payload? = nil
    ) throws -> URLRequest {
        
        try RequestFactory.createGetUINDataRequest(
            url: url,
            payload: payload ?? makePayload()
        )
    }
    
    private func makePayload(
        uin: String = anyMessage()
    ) -> Payload {
        
        return .init(uin: uin)
    }
    
    private struct Body: Decodable {
        
        let UIN: String
    }
}
