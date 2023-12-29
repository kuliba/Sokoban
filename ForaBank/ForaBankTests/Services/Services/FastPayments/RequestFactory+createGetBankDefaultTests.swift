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
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.httpBody = try JSONSerialization.data(withJSONObject: [
            "phoneNumber": payload.rawValue
        ] as [String: String])
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        return request
    }
}

@testable import ForaBank
import XCTest

final class RequestFactory_createGetBankDefaultRequestTests: XCTestCase {
    
    func test_makeRequest_shouldSetURL() throws {
        
        let url = anyURL()
        let request = try makeRequest(url: url)
        
        XCTAssertNoDiff(request.url, url)
    }
    
    func test_makeRequest_shouldSetHTTPMethodToGET() throws {
        
        let request = try makeRequest()
        
        XCTAssertNoDiff(request.httpMethod, "GET")
    }
    
    func test_makeRequest_shouldSetCachePolicy() throws {
        
        let request = try makeRequest()
        
        XCTAssertNoDiff(request.cachePolicy, .reloadIgnoringLocalAndRemoteCacheData)
    }
    
    func test_makeRequest_shouldSetHTTPBody() throws {
        
        let payload = anyPayload()
        let request = try makeRequest(payload: payload)
     
        let body = try request.decodedBody(as: Payload.self)
        XCTAssertNoDiff(body.phoneNumber, payload.rawValue)
    }
    
    // MARK: - Helpers
    
    private func makeRequest(
        url: URL = anyURL(string: "any-url"),
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
    
    private struct Payload: Decodable {
        
        let phoneNumber: String
    }
}
