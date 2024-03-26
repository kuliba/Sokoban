//
//  RequestFactory+createCreateAnywayTransferRequestTests.swift
//
//
//  Created by Igor Malyarov on 25.03.2024.
//

@testable import AnywayPayment
import RemoteServices
import XCTest

final class RequestFactory_createCreateAnywayTransferRequestTests: XCTestCase {
    
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
        
        let payload = makePayload()
        let request = try createRequest(payload: payload)
        let body = try request.decodedBody(as: RequestFactory._DTO.self)
        
        XCTAssertEqual(body, RequestFactory._DTO(payload))
    }
    
    // MARK: - Helpers
    
    private func createRequest(
        url: URL = anyURL(),
        payload: RequestFactory.CreateAnywayTransferResponsePayload = makePayload()
    ) throws -> URLRequest {
        
        try RequestFactory.createCreateAnywayTransferRequest(
            url: url,
            payload: payload
        )
    }
}

private func makePayload(
    fieldID: Int = generateRandom11DigitNumber(),
    fieldName: String = UUID().uuidString,
    fieldValue: String = UUID().uuidString
) -> RequestFactory.CreateAnywayTransferResponsePayload {
    
    .init(
        additionals: [
            .init(
                fieldID: fieldID,
                fieldName: fieldName,
                fieldValue: fieldValue
            )
        ],
        check: false
    )
}
