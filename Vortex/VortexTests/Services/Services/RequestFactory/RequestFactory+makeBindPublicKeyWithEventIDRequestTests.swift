//
//  RequestFactory+makeBindPublicKeyWithEventIDRequestTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 05.08.2023.
//

import CvvPin
@testable import Vortex
import URLRequestFactory
import XCTest

final class RequestFactory_makeBindPublicKeyWithEventIDRequestTests: XCTestCase {
    
    func test_makeBindPublicKeyWithEventIDRequest_shouldThrowOnEmptyEventID() throws {
        
        try XCTAssertThrowsAsNSError(
            makeRequest(eventID: ""),
            error: URLRequestFactory.Service.Error.bindPublicKeyWithEventIDEmptyEventID
        )
    }
    
    func test_makeRequest_shouldThrowOnEmptyKey() throws {
        
        try XCTAssertThrowsAsNSError(
            makeRequest(keyString: ""),
            error: URLRequestFactory.Service.Error.bindPublicKeyWithEventIDEmptyKey
        )
    }
    
    func test_makeRequest_shouldSetRequestURL() throws {
        
        let request = try makeRequest().request
        
        XCTAssertEqual(
            request.url?.absoluteString,
            "https://dmz-api-gate-test.\(Config.domen)/processing/registration/v1/bindPublicKeyWithEventId"
        )
    }
    
    func test_makeRequest_shouldSetRequestMethodToPost() throws {
        
        let request = try makeRequest().request
        
        XCTAssertEqual(request.httpMethod, "POST")
    }
    
    func test_makeRequest_shouldSetRequestBody() throws {
        
        let (publicKeyWithEventID, request) = try makeRequest()
        let httpBody = try XCTUnwrap(request.httpBody)
        let decodedRequest = try JSONDecoder().decode(
            DecodablePublicKeyWithEventID.self,
            from: httpBody
        )
        
        XCTAssertNoDiff(
            decodedRequest.publicKeyWithEventID,
            publicKeyWithEventID
        )
    }
    
    // MARK: - Helpers
    
    private func makeRequest(
        eventID: String = "any eventID",
        keyString: String = "any data"
    ) throws -> (
        publicKeyWithEventID: PublicKeyWithEventID,
        request: URLRequest
    ) {
        let publicKeyWithEventID = anyPublicKeyWithEventID(
            eventID: eventID,
            keyData: Data(keyString.utf8)
        )
        
        let request = try RequestFactory.makeBindPublicKeyWithEventIDRequest(with: publicKeyWithEventID)
        
        return (publicKeyWithEventID, request)
    }
    
    private func anyPublicKeyWithEventID(
        eventID: String = "any eventID",
        keyData: Data = Data("any data".utf8)
    ) -> PublicKeyWithEventID {
        
        .init(
            key: .init(keyData: keyData),
            eventID: .init(value: eventID)
        )
    }
    
    private struct DecodablePublicKeyWithEventID: Decodable {
        
        let data: String
        let eventId: String
        
        init(_ publicKeyWithEventID: PublicKeyWithEventID) {
            
            self.data = publicKeyWithEventID.key.base64String
            self.eventId = publicKeyWithEventID.eventID.value
        }
        
        var publicKeyWithEventID: PublicKeyWithEventID? {
            
            Data(
                base64Encoded: data,
                options: .ignoreUnknownCharacters
            ).map {
                
                .init(
                    key: .init(keyData: $0),
                    eventID: .init(value: eventId)
                )
            }
        }
    }
}
