//
//  RequestFactory+getSberQRDataTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 07.12.2023.
//

@testable import ForaBank
import XCTest

final class RequestFactory_getSberQRDataTests: XCTestCase {
    
    func test_createGetSberQRRequest_shouldSetRequestURL() throws {
        
        let request = try createGetSberQRRequest()
        
        XCTAssertEqual(
            request.url?.absoluteString,
            "https://pl.innovation.ru/dbo/api/v3/rest/binding/v1/getSberQRData"
        )
    }
    
    func test_createGetSberQRRequest_shouldSetRequestMethodToPost() throws {
        
        let request = try createGetSberQRRequest()
        
        XCTAssertEqual(request.httpMethod, "POST")
    }
    
    func test_createGetSberQRRequest_shouldSetRequestBody() throws {
        
        let url = anyURL()
        let request = try createGetSberQRRequest(url: url)
        let data = try XCTUnwrap(request.httpBody)
        let decodedRequest = try JSONDecoder().decode(DecodableQRLink.self, from: data)
        
        XCTAssertNoDiff(decodedRequest.url, url)
    }
    
    // MARK: - Helpers
    
    private func createGetSberQRRequest(
        url: URL = anyURL()
    ) throws -> URLRequest {
        
        try RequestFactory.createGetSberQRRequest(url)
    }
    
    private struct DecodableQRLink: Decodable {
        
        let url: URL
        
        enum CodingKeys: String, CodingKey {
            
            case url = "QRLink"
        }
    }
}
