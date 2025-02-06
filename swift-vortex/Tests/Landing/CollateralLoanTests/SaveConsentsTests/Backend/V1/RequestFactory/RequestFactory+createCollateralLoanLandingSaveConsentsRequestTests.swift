//
//  RequestFactory+createCollateralLoanLandingSaveConsentsRequestTests.swift
//
//
//  Created by Valentin Ozerov on 24.10.2024.
//

import RemoteServices
import XCTest
import CollateralLoanLandingSaveConsentsBackend

final class RequestFactory_createCollateralLoanLandingSaveConsentsRequestTests: XCTestCase {
    
    func test_createRequest_shouldSetHTTPMethodToPOST() throws {
        
        let request = try RequestFactory.createSaveConsentsRequest(url: anyURL(), payload: anyPayload())
        
        XCTAssertNoDiff(request.httpMethod, "POST")
    }
    
    func test_createRequest_shouldSetCachePolicy() throws {
        
        let request = try RequestFactory.createSaveConsentsRequest(url: anyURL(), payload: anyPayload())

        XCTAssertNoDiff(request.cachePolicy, .reloadIgnoringLocalAndRemoteCacheData)
    }
    
    func test_createRequest_shouldSetWithHTTPBody() throws {
        
        let payload = anyPayload()
        let request = try createRequest(payload: payload)
        
        let body = try request.decodedBody(as: Body.self)
        XCTAssertNoDiff(body.payload, payload)
    }
}

extension RequestFactory_createCollateralLoanLandingSaveConsentsRequestTests {
    
    typealias Payload = RequestFactory.SaveConsentsPayload
}

// MARK: - Helpers

private func createRequest(
    url: URL = anyURL(),
    payload: RequestFactory.SaveConsentsPayload = anyPayload()
) throws -> URLRequest {
    
    try RequestFactory.createSaveConsentsRequest(
        url: url,
        payload: payload
    )
}

private func anyPayload(
    applicationID: UInt = .random(in: (0...UInt.max)),
    verificationCode: String = anyMessage()
) -> RequestFactory.SaveConsentsPayload {
    
    .init(
        applicationID: applicationID,
        verificationCode: verificationCode
    )
}

private struct Body: Decodable {
    
    let applicationId: UInt
    let verificationCode: String
    
    var payload: RequestFactory.SaveConsentsPayload {
        
        .init(applicationID: applicationId, verificationCode: verificationCode)
    }
}
