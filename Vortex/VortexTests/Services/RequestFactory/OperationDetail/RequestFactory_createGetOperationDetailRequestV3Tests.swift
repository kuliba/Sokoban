//
//  RequestFactory_createGetOperationDetailRequestV3Tests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 21.02.2025.
//

@testable import Vortex
import RemoteServices
import XCTest

final class RequestFactory_createGetOperationDetailRequestV3Tests: XCTestCase {
    
    func test_createRequest_shouldSetRequestURL() throws {
        
        let request = try createRequest()
        
        XCTAssertNoDiff(
            request.url?.absoluteString,
            "https://pl.\(Config.domen)/dbo/api/v3/rest/v3/getOperationDetail"
        )
    }
    
    func test_createRequest_shouldSetRequestMethodToPost() throws {
        
        let request = try createRequest()
        
        XCTAssertEqual(request.httpMethod, "POST")
    }
    
    func test_createRequest_shouldSetRequestBody() throws {
        
        let request = try createRequest(detailID: 4321)
        let decodedRequest = try JSONDecoder().decode(
            DetailID.self,
            from: XCTUnwrap(request.httpBody)
        )
        
        XCTAssertNoDiff(decodedRequest.paymentOperationDetailId, 4321)
    }
    
    // MARK: - Helpers
    
    private func createRequest(
        detailID: Int = .random(in: 1...1_000)
    ) throws -> URLRequest {
        
        try Vortex.RequestFactory.createGetOperationDetailRequestV3(detailID: detailID)
    }
    
    private struct DetailID: Decodable {
        
        let paymentOperationDetailId: Int
    }
}
