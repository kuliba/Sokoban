//
//  RequestFactory+createGetPrintFormForApplicationOrderingCardRequestTests.swift
//
//
//  Created by Дмитрий Савушкин on 20.03.2025.
//

import Foundation
import RemoteServices
import XCTest
import GetCardOrderFormService

final class RequestFactory_createGetPrintFormForApplicationOrderingCardRequestTests: XCTestCase {
    
    func test_createRequest_shouldSetURL() throws {
        
        let url = anyURL()
        let request = try createRequest(url: url)
        
        XCTAssertNoDiff(request.url?.absoluteString, url.absoluteString)
    }
    
    func test_createRequest_shouldSetHTTPMethodToPost() throws {
        
        let request = try createRequest()
        
        XCTAssertNoDiff(request.httpMethod, "POST")
    }
    
    func test_createRequest_shouldSetCachePolicy() throws {
        
        let request = try createRequest()
        
        XCTAssertNoDiff(request.cachePolicy, .reloadIgnoringLocalAndRemoteCacheData)
    }
    
    func test_createRequest_detailIdNotNil_shouldSetHTTPBody() throws {
        
        let payload = anyPayload(requestId: anyString())
        let request = try createRequest(payload: payload)
        
        let body = try request.decodedBody(as: Body.self)
        
        XCTAssertNoDiff(body.payload.requestId, payload.requestId)
    }

    // MARK: - Helpers
    
    private func createRequest(
        payload: GetPrintFormPayload = .init(requestId: "String"),
        url: URL = anyURL()
    ) throws -> URLRequest {
        
        try RequestFactory.createGetPrintFormForApplicationOrderingCardRequest(payload: payload, url: url)
    }
    
    private func anyString() -> String {
        
        UUID().uuidString
    }
    
    private func anyPayload(
        requestId: String = "String"
    ) -> GetPrintFormPayload {
        
        .init(requestId: requestId)
    }

    private struct Body: Decodable {
        
        let requestId: String

        var payload: GetPrintFormPayload {
            
            .init(requestId: requestId)
        }
    }
}

extension URLRequest {
    
    func decodedBody<T: Decodable>(as type: T.Type) throws -> T {
        
        let data = try XCTUnwrap(httpBody)
        return try JSONDecoder().decode(T.self, from: data)
    }
}
