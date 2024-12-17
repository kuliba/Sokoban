//
//  RequestFactory+createGetPrintFormRequestTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 22.11.2023.
//

@testable import ForaBank
import XCTest

final class RequestFactory_createGetPrintFormRequestTests: XCTestCase {
    
    func test_makeRequest_shouldSetRequestURL() throws {
        
        let request = try makeRequest()
        
        XCTAssertEqual(
            request.url?.absoluteString,
            "https://pl.forabank.ru/dbo/api/v3/rest/getPrintForm"
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
        
        XCTAssertNoDiff(decodedRequest.paymentOperationDetailId, "\(documentID.rawValue)")
        XCTAssertNoDiff(decodedRequest.printFormType, "sticker")
    }
    
    // MARK: - Helpers
    
    private func makeRequest(
        _ documentID: DocumentID? = nil
    ) throws -> URLRequest {
        
        let createRequest = RequestFactory.createGetPrintFormRequest(printFormType: .sticker)
        return try createRequest(documentID ?? makeDocumentID())
    }
    
    private func makeDocumentID(
        _ documentIDValue: Int = 1234567
    ) -> DocumentID {
        
        .init(documentIDValue)
    }
    
    private struct DecodableRequest: Decodable {
        
        let paymentOperationDetailId: String
        let printFormType: String
    }
}
