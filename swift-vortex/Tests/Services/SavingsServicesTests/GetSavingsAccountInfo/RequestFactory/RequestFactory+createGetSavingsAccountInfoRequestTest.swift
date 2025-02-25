//
//  RequestFactory+createGetSavingsAccountInfoRequestTest.swift
//
//
//  Created by Andryusina Nataly on 25.02.2025.
//

import SavingsServices
import RemoteServices
import XCTest

final class RequestFactory_createGetSavingsAccountInfoRequestTests: XCTestCase {
    
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
            accountID: .random(in: 0..<20)
        )
        let request = try createRequest(payload: payload)
        let body = try request.decodedBody(as: _DTO.self)
        
        XCTAssertEqual(body, _DTO(payload))
    }
        
    // MARK: - Helpers
    
    private func createRequest(
        url: URL = anyURL(),
        payload: GetSavingsAccountInfoPayload = makePayload(accountID: 1)
    ) throws -> URLRequest {
        
        try RequestFactory.createGetSavingsAccountInfoRequest(
            payload: payload,
            url: url
        )
    }
}

private struct _DTO: Decodable, Equatable {
    
    let accountNumber: Int
}

private extension _DTO {
    
    init(_ payload: GetSavingsAccountInfoPayload) {
        
        self.init(accountNumber: payload.accountID)
    }
}

private func makePayload(
    accountID: Int
) -> GetSavingsAccountInfoPayload {
    
    .init(accountID: accountID)
}
