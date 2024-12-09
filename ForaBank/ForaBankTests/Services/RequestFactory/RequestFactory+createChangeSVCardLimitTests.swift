//
//  RequestFactory+createChangeSVCardLimitTests.swift
//  VortexTests
//
//  Created by Andryusina Nataly on 08.07.2024.
//

@testable import Vortex
import RemoteServices
import SVCardLimitAPI
import XCTest

final class RequestFactory_createChangeSVCardLimitTests: XCTestCase {
    
    func test_createRequest_shouldSetRequestURL() throws {
        
        let request = try createRequest()
        
        XCTAssertEqual(
            request.url?.absoluteString,
            "https://pl.\(Config.domen)/dbo/api/v3/rest/changeSVCardLimit"
        )
    }
    
    func test_createRequest_shouldSetRequestMethodToPost() throws {
        
        let request = try createRequest()
        
        XCTAssertEqual(request.httpMethod, "POST")
    }
    
    func test_createRequest_shouldSetRequestBody() throws {
        
        let request = try createRequest(payload: .init(cardId: 1, limit: .init(name: "limit", value: 10)))
        let decodedRequest = try JSONDecoder().decode(
            _ChangeSVCardLimitPayload.self,
            from: XCTUnwrap(request.httpBody)
        )
        
        XCTAssertNoDiff(decodedRequest.cardId, 1)
        XCTAssertNoDiff(decodedRequest.limit.name, "limit")
        XCTAssertNoDiff(decodedRequest.limit.value, 10)
    }

    // MARK: - Helpers
    
    private func createRequest(
        payload: ChangeSVCardLimitPayload = .init(cardId: 1, limit: .init(name: "limit", value: 10))
    ) throws -> URLRequest {
        
        try ForaBank.RequestFactory.createChangeSVCardLimitRequest(payload: payload)
    }
    
    private struct _ChangeSVCardLimitPayload: Decodable {
        
        let cardId: Int
        let limit: _Limit
        
        struct _Limit: Decodable {
            
            let name: String
            let value: Decimal
        }
    }
}
