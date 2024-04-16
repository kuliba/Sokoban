//
//  RequestFactory+createGetOperationDetailByPaymentIDRequestTests.swift
//
//
//  Created by Igor Malyarov on 25.03.2024.
//

import AnywayPaymentBackend
import RemoteServices
import XCTest

final class RequestFactory_createGetOperationDetailByPaymentIDRequestTests: XCTestCase {
    
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
        XCTAssertNoDiff(body.paymentOperationDetailId, payload.rawValue)
    }
    
    func test_createRequest_shouldSetHTTPBody_JSON() throws {
        
        let payload = anyPayload()
        let request = try createRequest(payload: payload)
        
        try assertBody(of: request, hasJSON: """
        {
            "paymentOperationDetailId": \(payload.rawValue)
        }
        """
        )
    }
    
    // MARK: - Helpers
    
    private func createRequest(
        url: URL = anyURL(),
        payload: RequestFactory.OperationDetailID = 123456
    ) throws -> URLRequest {
        
        try RequestFactory.createGetOperationDetailByPaymentIDRequest(
            url: url,
            payload: payload
        )
    }
    
    private func anyPayload(
        _ value: Int = generateRandom11DigitNumber()
    ) -> RequestFactory.OperationDetailID {
        
        .init(value)
    }
    
    private struct Body: Decodable {
        
        let paymentOperationDetailId: Int
    }
}
