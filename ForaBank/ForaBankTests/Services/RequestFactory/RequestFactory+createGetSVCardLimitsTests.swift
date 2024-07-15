//
//  RequestFactory+createGetSVCardLimitsTests.swift
//  ForaBankTests
//
//  Created by Andryusina Nataly on 05.07.2024.
//

@testable import ForaBank
import RemoteServices
import SVCardLimitAPI
import XCTest

final class RequestFactory_createGetSVCardLimitsTests: XCTestCase {
    
    func test_createRequest_shouldSetRequestURL() throws {
        
        let request = try createRequest()
        
        XCTAssertEqual(
            request.url?.absoluteString,
            "https://pl.forabank.ru/dbo/api/v3/rest/getSVCardLimits"
        )
    }
    
    func test_createRequest_shouldSetRequestMethodToPost() throws {
        
        let request = try createRequest()
        
        XCTAssertEqual(request.httpMethod, "POST")
    }
    
    func test_createRequest_shouldSetRequestBody() throws {
        
        let request = try createRequest(payload: .init(cardId: 1))
        let decodedRequest = try JSONDecoder().decode(
            SVCardLimitsPayload.self,
            from: XCTUnwrap(request.httpBody)
        )
        
        XCTAssertNoDiff(decodedRequest.cardId, 1)
    }

    // MARK: - Helpers
    
    private func createRequest(
        payload: GetSVCardLimitsPayload = .init(cardId: 1)
    ) throws -> URLRequest {
        
        try ForaBank.RequestFactory.createGetSVCardLimitsRequest(payload: payload)
    }
    
    private struct SVCardLimitsPayload: Decodable {
        
        let cardId: Int
    }
}
