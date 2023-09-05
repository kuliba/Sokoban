//
//  RequestFactory+makeSecretRequestTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 05.08.2023.
//

import CvvPin
@testable import ForaBank
import XCTest

final class RequestFactory_makeSecretRequestTests: XCTestCase {
    
    // MARK: - makeSecretRequest
    
    func test_makeSecretRequest_shouldThrowOnEmptyCode() throws {
        
        XCTAssertThrowsError(
            try makeSecretRequest(code: "")
        ) {
            XCTAssertNoDiff(
                $0 as? RequestFactory.SecretRequestError,
                .emptyCode
            )
        }
    }
    
    func test_makeSecretRequest_shouldThrowOnEmptyData() throws {
        
        XCTAssertThrowsError(
            try makeSecretRequest(data: "")
        ) {
            XCTAssertNoDiff(
                $0 as? RequestFactory.SecretRequestError,
                .emptyData
            )
        }
    }
    
    func test_makeSecretRequest_shouldSetRequestURL() throws {
        
        let request = try makeSecretRequest().request
        
        XCTAssertEqual(
            request.url?.absoluteString,
            "https://dmz-api-gate-test.forabank.ru/processing/registration/v1/formSessionKey"
        )
    }
    
    func test_makeSecretRequest_shouldSetRequestMethodToPost() throws {
        
        let request = try makeSecretRequest().request
        
        XCTAssertEqual(request.httpMethod, "POST")
    }
    
    func test_makeSecretRequest_shouldSetRequestBody() throws {
        
        let (secretRequest, request) = try makeSecretRequest()
        let data = try XCTUnwrap(request.httpBody)
        let decodedRequest = try JSONDecoder().decode(DecodableSecretRequest.self, from: data)
        
        XCTAssertNoDiff(secretRequest, decodedRequest.secretRequest)
    }
    
    // MARK: - Helpers
    
    private func makeSecretRequest(
        code: String = "any code",
        data: String = "any data"
    ) throws -> (
        secretRequest: SecretRequest,
        request: URLRequest
    ) {
        let secretRequest = anySecretRequest(code: code, data: data)
        
        let request = try RequestFactory.createSecretRequest(from: secretRequest)
        
        return (secretRequest, request)
    }
    
    private func anySecretRequest(
        code: String = "any code",
        data: String = "any data"
    ) -> SecretRequest {
        
        .init(code: code, data: data)
    }
    
    private struct DecodableSecretRequest: Decodable {
        
        let code: String
        let data: String
        
        init(secretRequest: SecretRequest) {
            
            self.code = secretRequest.code
            self.data = secretRequest.data
        }
        
        var secretRequest: SecretRequest {
            
            .init(code: code, data: data)
        }
    }
}
