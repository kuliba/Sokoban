//
//  RequestFactory+createGetOperationDetailByPaymentIDRequestTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 21.11.2023.
//

@testable import Vortex
import XCTest

final class RequestFactory_createGetOperationDetailByPaymentIDRequestTests: XCTestCase {
    
    func test_makeRequest_shouldThrowOnEmptyDocumentID() throws {
        
        let documentID = makePaymentID("")
        
        try XCTAssertThrowsAsNSError(
            makeRequest(documentID),
            error: RequestFactory.GetOperationDetailByPaymentIDError.invalidDocumentID
        )
    }
    
    func test_makeRequest_shouldSetRequestURL() throws {
        
        let request = try makeRequest()
        
        XCTAssertEqual(
            request.url?.absoluteString,
            "https://pl.\(Config.domen)/dbo/api/v3/rest/getOperationDetailByPaymentId"
        )
    }
    
    func test_makeRequest_shouldSetRequestMethodToPost() throws {
        
        let request = try makeRequest()
        
        XCTAssertEqual(request.httpMethod, "POST")
    }
    
    func test_makeRequest_shouldSetRequestBody() throws {
        
        let documentID = makePaymentID()
        let request = try makeRequest(documentID)
        
        let httpBody = try XCTUnwrap(request.httpBody)
        let decodedRequest = try JSONDecoder().decode(
            DecodableRequest.self,
            from: httpBody
        )
        
        XCTAssertNoDiff(decodedRequest.paymentOperationDetailId, documentID.rawValue)
    }
    
    // MARK: - Helpers
    
    private func makeRequest(
        _ paymentID: PaymentID? = nil
    ) throws -> URLRequest {
        
        try RequestFactory.createGetOperationDetailByPaymentIDRequest(
            paymentID: paymentID ?? makePaymentID()
        )
    }
    
    private func makePaymentID(
        _ documentIDValue: String = UUID().uuidString
    ) -> PaymentID {
        
        .init(documentIDValue)
    }
    
    private struct DecodableRequest: Decodable {
        
        let paymentOperationDetailId: String
    }
}
