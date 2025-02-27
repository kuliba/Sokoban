//
//  RequestFactory+createGetPrintFormForSavingsAccountRequestTests.swift
//
//
//  Created by Andryusina Nataly on 24.02.2025.
//

import SavingsServices
import RemoteServices
import XCTest

final class RequestFactory_createGetPrintFormForSavingsAccountRequestTests: XCTestCase {
    
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
    
    func test_createRequest_detailIdNil_shouldSetHTTPBody() throws {
        
        let payload = anyPayload(detailId: nil)
        let request = try createRequest(payload: payload)
        
        let body = try request.decodedBody(as: Body.self)
        
        XCTAssertNoDiff(body.payload.accountId, payload.accountId)
        XCTAssertNoDiff(body.payload.detailId, payload.detailId)
    }
    
    func test_createRequest_detailIdNotNil_shouldSetHTTPBody() throws {
        
        let payload = anyPayload(detailId: anyInt())
        let request = try createRequest(payload: payload)
        
        let body = try request.decodedBody(as: Body.self)
        
        XCTAssertNoDiff(body.payload.accountId, payload.accountId)
        XCTAssertNoDiff(body.payload.detailId, payload.detailId)
    }
    
    func test_createRequest_shouldSetHTTPBody_JSON() throws {
        
        let accountID = anyInt()
        let detailID = anyInt()

        let payload = anyPayload(accountId: accountID, detailId: detailID)
        let request = try createRequest(payload: payload)
        
        try assertBody(of: request, hasJSON: """
        {
            "accountId": \(accountID),
            "paymentOperationDetailId": \(detailID)
        }
        """
        )
    }

    // MARK: - Helpers
    
    private func createRequest(
        payload: GetPrintFormPayload = .init(accountId: 1, detailId: nil),
        url: URL = anyURL()
    ) throws -> URLRequest {
        
        try RequestFactory.createGetPrintFormForSavingsAccountRequest(payload: payload, url: url)
    }
    
    private func anyInt() -> Int {
        
        .random(in: 0...Int.max)
    }
    
    private func anyPayload(
        accountId: Int = 1,
        detailId: Int? = nil
    ) -> GetPrintFormPayload {
        
        .init(accountId: accountId, detailId: detailId)
    }

    private struct Body: Decodable {
        
        let accountId: Int
        let paymentOperationDetailId: Int?

        var payload: GetPrintFormPayload {
            
            .init(accountId: accountId, detailId: paymentOperationDetailId)
        }
    }
}
