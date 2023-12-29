//
//  RequestFactory+createMakeSetBankDefaultRequestTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 29.12.2023.
//

import Foundation
import Tagged

extension RequestFactory {
    
    typealias VerificationCode = Tagged<_VerificationCode, String>
    enum _VerificationCode {}
    
    static func createMakeSetBankDefaultRequest(
        url: URL,
        payload: VerificationCode
    ) throws -> URLRequest {
        
        var request = createEmptyRequest(.post, with: url)
        request.httpBody = try payload.httpBody
        return request
    }
}

private extension RequestFactory.VerificationCode {
    
    var httpBody: Data {
        
        get throws {
            
            try JSONSerialization.data(withJSONObject: [
                "verificationCode": rawValue
            ] as [String: String])
        }
    }
}

import XCTest

final class RequestFactory_createMakeSetBankDefaultRequestTests: XCTestCase {
    
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
        XCTAssertNoDiff(body.verificationCode, payload.rawValue)
    }
    
    func test_makeRequest_shouldSetHTTPBody_JSON() throws {
        
        let payload = anyPayload()
        let request = try makeRequest(payload: payload)
        
        try assertBody(of: request, hasJSON: """
        {
            "verificationCode": "\(payload.rawValue)"
        }
        """
        )
    }
    
    // MARK: - Helpers
    
    private func makeRequest(
        url: URL = anyURL("any-url"),
        payload: RequestFactory.VerificationCode = .init(UUID().uuidString)
    ) throws -> URLRequest {
        
        try RequestFactory.createMakeSetBankDefaultRequest(
            url: url,
            payload: payload
        )
    }
    
    private func anyPayload(
        _ value: String = UUID().uuidString
    ) -> RequestFactory.VerificationCode {
        
        .init(value)
    }
    
    private struct Body: Decodable {
        
        let verificationCode: String
    }
}
