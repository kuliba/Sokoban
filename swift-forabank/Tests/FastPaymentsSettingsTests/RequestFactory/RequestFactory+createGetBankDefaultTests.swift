//
//  RequestFactory+createGetBankDefaultRequestTests.swift
//  
//
//  Created by Igor Malyarov on 29.12.2023.
//

import FastPaymentsSettings
import RemoteServices
import XCTest

final class RequestFactory_createGetBankDefaultRequestTests: XCTestCase {
    
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
        XCTAssertNoDiff(body.phoneNumber, payload.rawValue)
    }
    
    func test_createRequest_shouldSetHTTPBody_JSON() throws {
        
        let phoneNumber = "987654321"
        let request = try createRequest(payload: .init(phoneNumber))
        
        try assertBody(of: request, hasJSON: """
        {
            "phoneNumber": "\(phoneNumber)"
        }
        """
        )
    }
    
    // MARK: - Helpers
    
    private func createRequest(
        url: URL = anyURL(),
        payload: PhoneNumber = .init(UUID().uuidString)
    ) throws -> URLRequest {
        
        try RequestFactory.createGetBankDefaultRequest(
            url: url,
            payload: payload
        )
    }
    
    private func anyPayload(
        _ value: String = UUID().uuidString
    ) -> PhoneNumber {
        
        .init(value)
    }
    
    private struct Body: Decodable {
        
        let phoneNumber: String
    }
}
