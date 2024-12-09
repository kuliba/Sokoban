//
//  RequestFactory+makeRequestTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 11.10.2023.
//

@testable import Vortex
import XCTest
import URLRequestFactory

final class RequestFactory_makeChangePINRequestTests: XCTestCase {
    
    func test_makeRequest_shouldThrowOnEmptySessionID() throws {
        
        let (sessionID, data) = (makeSessionID(""), anyData())
        
        try XCTAssertThrowsAsNSError(
            makeRequest(sessionID, data),
            error: URLRequestFactory.Service.Error.emptySessionID
        )
    }
    
    func test_makeRequest_shouldThrowOnEmptyData() throws {
        
        let (sessionID, data) = (makeSessionID(), Data())
        
        try XCTAssertThrowsAsNSError(
            makeRequest(sessionID, data),
            error: URLRequestFactory.Service.Error.emptyData
        )
    }
    
    func test_makeRequest_shouldSetRequestURL() throws {
        
        let request = try makeRequest()
        
        XCTAssertEqual(
            request.url?.absoluteString,
            "https://dmz-api-gate-test.\(Config.domen)/processing/cardInfo/v1/changePIN"
        )
    }
    
    func test_makeRequest_shouldSetRequestMethodToPost() throws {
        
        let request = try makeRequest()
        
        XCTAssertEqual(request.httpMethod, "POST")
    }
    
    func test_makeRequest_shouldSetRequestBody() throws {
        
        let (sessionID, data) = (makeSessionID(), anyData())
        let request = try makeRequest(sessionID, data)
        
        let httpBody = try XCTUnwrap(request.httpBody)
        let decodedRequest = try JSONDecoder().decode(
            DecodableRequest.self,
            from: httpBody
        )
        
        XCTAssertNoDiff(decodedRequest.sessionId, sessionID.sessionIDValue)
        XCTAssertNoDiff(decodedRequest.dataAsData, data)
    }
    
    // MARK: - Helpers
    
    private func makeRequest(
        _ sessionID: Vortex.SessionID = makeSessionID(),
        _ data: Data = .init("any data".utf8)
    ) throws -> URLRequest {
        
        try RequestFactory.makeChangePINRequest(
            sessionID: sessionID,
            data: data
        )
    }
    
    private struct DecodableRequest: Decodable {
        
        let sessionId: String
        let data: String
        
        var dataAsData: Data? {
            
            .init(base64Encoded: data, options: .ignoreUnknownCharacters)
        }
    }
}
