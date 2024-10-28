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
        request.httpBody = try Payload.stub.httpBody

        XCTAssertNotNil(request.httpBody)
    }
}

extension RequestFactory_createCollateralLoanLandingSaveConsentsRequestTests {
    
    typealias Payload = RequestFactory.CreateSaveConsentsCollateralLoanApplicationPayload
}

// MARK: - Helpers

private extension RequestFactory.CreateSaveConsentsCollateralLoanApplicationPayload {
    
    static let stub = Self(applicationId: .random(in: (0...Int.max)), verificationCode: anyMessage())
    
    var httpBody: Data {
        
        get throws {
            
            try JSONSerialization.data(withJSONObject: [
                "applicationId": applicationId,
                "verificationCode": verificationCode
            ] as [String: Any])
        }
    }
}
