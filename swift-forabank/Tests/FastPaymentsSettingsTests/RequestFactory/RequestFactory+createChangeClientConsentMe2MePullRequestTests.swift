//
//  RequestFactory+createChangeClientConsentMe2MePullRequestTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 29.12.2023.
//

import Foundation
import Tagged

extension RequestFactory {
    
    typealias BankIDList = [BankID]
    typealias BankID = Tagged<_BankID, String>
    enum _BankID {}
    
    static func createChangeClientConsentMe2MePullRequest(
        url: URL,
        payload: BankIDList
    ) throws -> URLRequest {
        
        var request = createEmptyRequest(.post, with: url)
        request.httpBody = try payload.httpBody
        return request
    }
}

private extension RequestFactory.BankIDList {
    
    var httpBody: Data {
        
        get throws {
            
            try JSONSerialization.data(withJSONObject: [
                "bankIdList": map(\.rawValue)
            ] as [String: [String]])
        }
    }
}

import XCTest

final class RequestFactory_createChangeClientConsentMe2MePullRequestTests: XCTestCase {
    
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
        XCTAssertNoDiff(body.payload, payload)
    }
    
    func test_makeRequest_shouldSetHTTPBody_JSON() throws {
        
        let id = UUID().uuidString
        let id2 = UUID().uuidString
        let id3 = UUID().uuidString
        let id4 = UUID().uuidString
        let payload = anyPayload([id, id2, id3, id4])
        let request = try makeRequest(payload: payload)
        
        try assertBody(of: request, hasJSON: """
        {
            "bankIdList": [
                "\(id)",
                "\(id2)",
                "\(id3)",
                "\(id4)"
            ]
        }
        """
        )
    }
    
    // MARK: - Helpers
    
    private func makeRequest(
        url: URL = anyURL("any-url"),
        payload: RequestFactory.BankIDList = [.init(UUID().uuidString)]
    ) throws -> URLRequest {
        
        try RequestFactory.createChangeClientConsentMe2MePullRequest(
            url: url,
            payload: payload
        )
    }
    
    private func anyPayload(
        _ value: [String] = [UUID().uuidString]
    ) -> RequestFactory.BankIDList {
        
        value.map(RequestFactory.BankID.init(rawValue:))
    }
    
    private struct Body: Decodable {
        
        let bankIdList: [String]
        
        var payload: RequestFactory.BankIDList {
            
            bankIdList.map(RequestFactory.BankID.init(rawValue:))
        }
    }
}
