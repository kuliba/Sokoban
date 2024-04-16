//
//  RequestFactory+createChangeClientConsentMe2MePullRequestTests.swift
//  
//
//  Created by Igor Malyarov on 29.12.2023.
//

import FastPaymentsSettings
import RemoteServices
import XCTest

final class RequestFactory_createChangeClientConsentMe2MePullRequestTests: XCTestCase {
    
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
        XCTAssertNoDiff(body.payload, payload)
    }
    
    func test_createRequest_shouldSetHTTPBody_JSON() throws {
        
        let id = UUID().uuidString
        let id2 = UUID().uuidString
        let id3 = UUID().uuidString
        let id4 = UUID().uuidString
        let payload = anyPayload([id, id2, id3, id4])
        let request = try createRequest(payload: payload)
        
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
    
    private func createRequest(
        url: URL = anyURL(),
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
