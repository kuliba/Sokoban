//
//  RequestFactory+createGetOperationDetailByPaymentIDRequestModuleTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 26.03.2024.
//

@testable import Vortex
import RemoteServices
import XCTest

final class RequestFactory_createGetOperationDetailByPaymentIDRequestModuleTests: XCTestCase {
    
    func test_createRequest_shouldSetRequestURL() throws {
        
        let request = try createRequest()
        
        XCTAssertEqual(
            request.url?.absoluteString,
            "https://pl.\(Config.domen)/dbo/api/v3/rest/v2/getOperationDetailByPaymentId"
        )
    }
    
    func test_createRequest_shouldSetRequestMethodToPost() throws {
        
        let request = try createRequest()
        
        XCTAssertEqual(request.httpMethod, "POST")
    }
    
    func test_createRequest_shouldSetRequestBody() throws {
        
        let request = try createRequest(payload: 432)
        let decodedRequest = try JSONDecoder().decode(
            DetailID.self,
            from: XCTUnwrap(request.httpBody)
        )
        
        XCTAssertNoDiff(decodedRequest.paymentOperationDetailId, 432)
    }

    // MARK: - Helpers
    
    private func createRequest(
        payload: RemoteServices.RequestFactory.OperationDetailID = 87654
    ) throws -> URLRequest {
        
        try Vortex.RequestFactory.createGetOperationDetailByPaymentIDRequestModule(payload)
    }
    
    private struct DetailID: Decodable {
        
        let paymentOperationDetailId: Int
    }
}
