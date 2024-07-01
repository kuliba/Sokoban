//
//  RequestFactory_createMakeTransferV2RequestTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 25.06.2024.
//

@testable import ForaBank
import RemoteServices
import XCTest

final class RequestFactory_createMakeTransferV2RequestTests: XCTestCase {
    
    func test_createRequest_shouldSetRequestURL() throws {
        
        let request = try createRequest()
        
        XCTAssertEqual(
            request.url?.absoluteString,
            "https://pl.forabank.ru/dbo/api/v3/rest/transfer/v2/makeTransfer"
        )
    }
    
    func test_createRequest_shouldSetRequestMethodToPost() throws {
        
        let request = try createRequest()
        
        XCTAssertEqual(request.httpMethod, "POST")
    }
    
    func test_createRequest_shouldSetRequestBody() throws {
        
        let request = try createRequest(payload: "876543")
        let decodedRequest = try JSONDecoder().decode(
            Code.self,
            from: XCTUnwrap(request.httpBody)
        )
        
        XCTAssertNoDiff(decodedRequest.verificationCode, "876543")
    }

    // MARK: - Helpers
    
    private func createRequest(
        payload: RemoteServices.RequestFactory.VerificationCode = .init(UUID().uuidString)
    ) throws -> URLRequest {
        
        try ForaBank.RequestFactory.createMakeTransferV2Request(payload)
    }
    
    private struct Code: Decodable {
        
        let verificationCode: String
    }
}
