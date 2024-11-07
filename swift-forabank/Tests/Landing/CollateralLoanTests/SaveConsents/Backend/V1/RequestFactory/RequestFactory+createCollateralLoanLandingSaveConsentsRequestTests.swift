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
        
        let request = RequestFactory.createEmptyRequest(.post, with: anyURL())
        
        XCTAssertNoDiff(request.httpMethod, "POST")
    }
    
    func test_createRequest_shouldSetCachePolicy() throws {
        
        let request = RequestFactory.createEmptyRequest(.post, with: anyURL())
        
        XCTAssertNoDiff(request.cachePolicy, .reloadIgnoringLocalAndRemoteCacheData)
    }
    
    func test_createRequest_shouldSetNilHTTPBody() throws {
        
        let request = RequestFactory.createEmptyRequest(.post, with: anyURL())
        
        XCTAssertNil(request.httpBody)
    }
    
    func test_createRequest_shouldSetNotNilHTTPBody() throws {
        
        var request = RequestFactory.createEmptyRequest(.post, with: anyURL())
        
        let payload = Body.stub
        request.httpBody = try payload.httpBody

        let decodedBody = try request.decodedBody(as: Body.self)
        
        XCTAssertNoDiff(decodedBody.applicationId, payload.applicationId)
        XCTAssertNoDiff(decodedBody.verificationCode, payload.verificationCode)
    }
}

extension RequestFactory_createCollateralLoanLandingSaveConsentsRequestTests {
    
    typealias Payload = RequestFactory.CreateCollateralLoanLandingSaveConsentsPayload
}

// MARK: - Helpers

private struct Body: Decodable {
    
    let applicationId: Int
    let verificationCode: String
    
    static let stub = Self(
        applicationId: .random(in: (0...Int.max)),
        verificationCode: anyMessage()
    )
}

extension Body {
    
    var httpBody: Data {

        get throws {
            
            let parameters: [String: Any] = [
                "applicationId": applicationId,
                "verificationCode": verificationCode
            ]
                        
            return try JSONSerialization.data(
                withJSONObject: parameters as [String: Any]
            )
        }
    }
}
