//
//  ResponseMapper+createGetOperationDetailByPaymentIDRequestTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 21.11.2023.
//

@testable import ForaBank
import XCTest

final class ResponseMapper_createGetOperationDetailByPaymentIDRequestTests: XCTestCase {
    
    func test_makeRequest_shouldThrowOnEmptyDocumentID() throws {
        
        let documentID = makeDocumentID("")
        
        try XCTAssertThrowsAsNSError(
            makeRequest(documentID),
            error: RequestFactory.GetOperationDetailByPaymentIDError.invalidDocumentID
        )
    }
    
    func test_makeRequest_shouldSetRequestURL() throws {
        
        let request = try makeRequest()
        
        XCTAssertEqual(
            request.url?.absoluteString,
            "https://pl.forabank.ru/dbo/api/v3/rest/getOperationDetailByPaymentId"
        )
    }
    
    func test_makeRequest_shouldSetRequestMethodToPost() throws {
        
        let request = try makeRequest()
        
        XCTAssertEqual(request.httpMethod, "POST")
    }
    
    func test_makeRequest_shouldSetRequestBody() throws {
        
        let documentID = makeDocumentID()
        let request = try makeRequest(documentID)
        
        let httpBody = try XCTUnwrap(request.httpBody)
        let decodedRequest = try JSONDecoder().decode(
            DecodableRequest.self,
            from: httpBody
        )
        
        XCTAssertNoDiff(decodedRequest.documentId, documentID.rawValue)
    }
    
    // MARK: - Helpers
    
    private func makeRequest(
        _ documentID: PaymentID? = nil
    ) throws -> URLRequest {
        
        try RequestFactory.createGetOperationDetailByPaymentIDRequest(
            documentID: documentID ?? makeDocumentID()
        )
    }
    
    private func makeDocumentID(
        _ documentIDValue: String = UUID().uuidString
    ) -> PaymentID {
        
        .init(documentIDValue)
    }
    
    private struct DecodableRequest: Decodable {
        
        let documentId: String
    }
}
