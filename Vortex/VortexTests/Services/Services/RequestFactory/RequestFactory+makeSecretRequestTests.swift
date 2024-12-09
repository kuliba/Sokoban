//
//  RequestFactory+makeSecretRequestTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 05.08.2023.
//

import CvvPin
@testable import Vortex
import URLRequestFactory
import XCTest

final class RequestFactory_makeSecretRequestTests: XCTestCase {
    
    func test_makeRequest_shouldThrowOnEmptyCode() throws {
        
        try XCTAssertThrowsAsNSError(
            makeRequest(code: ""),
            error: URLRequestFactory.Service.Error.formSessionKeyEmptyCode
        )
    }
    
    func test_makeRequest_shouldThrowOnEmptyData() throws {
        
        try XCTAssertThrowsAsNSError(
            makeRequest(data: .empty),
            error: URLRequestFactory.Service.Error.formSessionKeyEmptyData
        )
    }
    
    func test_makeRequest_shouldSetRequestURL() throws {
        
        let request = try makeRequest().request
        
        XCTAssertEqual(
            request.url?.absoluteString,
            "https://dmz-api-gate-test.\(Config.domen)/processing/registration/v1/formSessionKey"
        )
    }
    
    func test_makeRequest_shouldSetRequestMethodToPost() throws {
        
        let request = try makeRequest().request
        
        XCTAssertEqual(request.httpMethod, "POST")
    }
    
    func test_makeRequest_shouldSetRequestBody() throws {
        
        let (secretRequest, request) = try makeRequest()
        let data = try XCTUnwrap(request.httpBody)
        let decodedRequest = try JSONDecoder().decode(DecodableSecretRequest.self, from: data)
        
        XCTAssertNoDiff(secretRequest, decodedRequest.secretRequest)
    }
    
    // MARK: - Helpers
    
    typealias SecretRequest = FormSessionKeyDomain.Request
    
    private func makeRequest(
        code: String = "any code",
        data: Data = anyData()
    ) throws -> (
        secretRequest: SecretRequest,
        request: URLRequest
    ) {
        let secretRequest = anySecretRequest(code: code, data: data)
        
        let request = try RequestFactory.makeSecretRequest(from: secretRequest)
        
        return (secretRequest, request)
    }
    
    private func anySecretRequest(
        code: String = "any code",
        data: Data = anyData()
    ) -> SecretRequest {
        
        .init(code: code, data: data)
    }
    
    private struct DecodableSecretRequest: Decodable {
        
        let code: String
        let data: String
        
        init(secretRequest: SecretRequest) {
            
            self.code = secretRequest.code
            self.data = secretRequest.data.base64EncodedString()
        }
        
        var secretRequest: SecretRequest {
            
            .init(code: code, data: Data(base64Encoded: data)!)
        }
    }
}
