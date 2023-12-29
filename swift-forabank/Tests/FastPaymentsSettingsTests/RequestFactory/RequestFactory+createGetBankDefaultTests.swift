//
//  RequestFactory+createGetBankDefaultRequestTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 29.12.2023.
//

import Foundation
import Tagged

extension RequestFactory {
    
    typealias PhoneNumber = Tagged<_PhoneNumber, String>
    enum _PhoneNumber {}
    
    static func createGetBankDefaultRequest(
        url: URL,
        payload: PhoneNumber
    ) throws -> URLRequest {
        
        var request = createEmptyRequest(.post, with: url)
        request.httpBody = try payload.httpBody
        return request
    }
}

private extension RequestFactory.PhoneNumber {
    
    var httpBody: Data {
        
        get throws {
            
            try JSONSerialization.data(withJSONObject: [
                "phoneNumber": rawValue
            ] as [String: String])
        }
    }
}

import XCTest

final class RequestFactory_createGetBankDefaultRequestTests: XCTestCase {
    
    func test_makeRequest_shouldSetURL() throws {
        
        let url = anyURL()
        let request = try makeRequest(url: url)
        
        XCTAssertNoDiff(request.url, url)
    }
    
    func test_makeRequest_shouldSetHTTPMethodToPOST() throws {
        
        let request = try makeRequest()
        
        XCTAssertNoDiff(request.httpMethod, "POST")
    }
    
    func test_makeRequest_shouldSetCachePolicy() throws {
        
        let request = try makeRequest()
        
        XCTAssertNoDiff(request.cachePolicy, .reloadIgnoringLocalAndRemoteCacheData)
    }
    
    func test_makeRequest_shouldSetHTTPBody() throws {
        
        let payload = anyPayload()
        let request = try makeRequest(payload: payload)
     
        let body = try request.decodedBody(as: Body.self)
        XCTAssertNoDiff(body.phoneNumber, payload.rawValue)
    }
    
    func test_makeRequest_shouldSetHTTPBody_JSON() throws {
        
        let phoneNumber = "987654321"
        let request = try makeRequest(payload: .init(phoneNumber))
        
        try assertBody(of: request, hasJSON: """
        {
            "phoneNumber": "\(phoneNumber)"
        }
        """
        )
    }
    
    // MARK: - Helpers
    
    private func makeRequest(
        url: URL = anyURL(),
        payload: RequestFactory.PhoneNumber = .init(UUID().uuidString)
    ) throws -> URLRequest {
        
        try RequestFactory.createGetBankDefaultRequest(
            url: url,
            payload: payload
        )
    }
    
    private func anyPayload(
        _ value: String = UUID().uuidString
    ) -> RequestFactory.PhoneNumber {
        
        .init(value)
    }
    
    private struct Body: Decodable {
        
        let phoneNumber: String
    }
}
