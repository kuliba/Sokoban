//
//  RequestFactory+makeBindPublicKeyWithEventIDRequestTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 05.08.2023.
//

import CvvPin
@testable import ForaBank
import XCTest

final class RequestFactory_makeBindPublicKeyWithEventIDRequestTests: XCTestCase {
    
    // MARK: - makeBindPublicKeyWithEventIDRequest
    
    func test_makeBindPublicKeyWithEventIDRequest_shouldThrowOnEmptyEventID() throws {
        
        XCTAssertThrowsError(
            try makeBindPublicKeyWithEventIDRequest(eventID: "")
        ) {
            XCTAssertNoDiff(
                $0 as? RequestFactory.PublicKeyWithEventIDError,
                .emptyEventID
            )
        }
    }
    
    func test_makeBindPublicKeyWithEventIDRequest_shouldThrowOnEmptyKeyString() throws {
        
        XCTAssertThrowsError(
            try makeBindPublicKeyWithEventIDRequest(keyString: "")
        ) {
            XCTAssertNoDiff(
                $0 as? RequestFactory.PublicKeyWithEventIDError,
                .emptyKeyString
            )
        }
    }
    
    func test_makeBindPublicKeyWithEventIDRequest_shouldSetRequestURL() throws {
        
        let request = try makeBindPublicKeyWithEventIDRequest().request
        
        XCTAssertEqual(
            request.url?.absoluteString,
            "https://dmz-api-gate-test.forabank.ru/processing/registration/v1/bindPublicKeyWithEventId"
        )
    }
    
    func test_makeBindPublicKeyWithEventIDRequest_shouldSetRequestMethodToPost() throws {
        
        let request = try makeBindPublicKeyWithEventIDRequest().request
        
        XCTAssertEqual(request.httpMethod, "POST")
    }
    
    func test_makeBindPublicKeyWithEventIDRequest_shouldSetRequestBody() throws {
        
        let (publicKeyWithEventID, request) = try makeBindPublicKeyWithEventIDRequest()
        let data = try XCTUnwrap(request.httpBody)
        let decodedRequest = try JSONDecoder().decode(DecodablePublicKeyWithEventID.self, from: data)
        
        XCTAssertNoDiff(publicKeyWithEventID, decodedRequest.publicKeyWithEventID)
    }
    
    // MARK: - Helpers
    
    private func makeBindPublicKeyWithEventIDRequest(
        eventID: String = "any eventID",
        keyString: String = "any data"
    ) throws -> (
        publicKeyWithEventID: PublicKeyWithEventID,
        request: URLRequest
    ) {
        let publicKeyWithEventID = anyPublicKeyWithEventID(eventID: eventID, keyString: keyString)
        
        let request = try RequestFactory.makeBindPublicKeyWithEventIDRequest(with: publicKeyWithEventID)
        
        return (publicKeyWithEventID, request)
    }
    
    private func anyPublicKeyWithEventID(
        eventID: String = "any eventID",
        keyString: String = "any data"
    ) -> PublicKeyWithEventID {
        
        .init(
            keyString: keyString,
            eventID: .init(value: eventID)
        )
    }
    
    private struct DecodablePublicKeyWithEventID: Decodable {
        
        let data: String
        let eventId: String
        
        init(_ publicKeyWithEventID: PublicKeyWithEventID) {
            
            self.data = publicKeyWithEventID.keyString
            self.eventId = publicKeyWithEventID.eventID.value
        }
        
        var publicKeyWithEventID: PublicKeyWithEventID {
            
            .init(
                keyString: data,
                eventID: .init(value: eventId)
            )
        }
    }
}
