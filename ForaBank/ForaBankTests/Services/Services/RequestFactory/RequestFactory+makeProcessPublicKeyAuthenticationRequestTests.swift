//
//  RequestFactory+makeProcessPublicKeyAuthenticationRequestTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 11.10.2023.
//

@testable import ForaBank
import XCTest
import URLRequestFactory

final class RequestFactory_makeProcessPublicKeyAuthenticationRequestTests: XCTestCase {
    
    func test_makeRequest_shouldThrowOnEmptyClientPublicKeyRSA() throws {
        
        try XCTAssertThrowsAsNSError(
            makeRequest(clientPublicKeyRSAValue: .init()),
            error: URLRequestFactory.Service.Error.processPublicKeyAuthenticationRequestEmptyClientPublicKeyRSA
        )
    }
    
    func test_makeRequest_shouldThrowOnEmptyPublicApplicationSessionKey() throws {
        
        try XCTAssertThrowsAsNSError(
            makeRequest(publicApplicationSessionKeyValue: .init()),
            error: URLRequestFactory.Service.Error.processPublicKeyAuthenticationRequestEmptyPublicApplicationSessionKey
        )
    }
    
    func test_makeRequest_shouldThrowOnEmptySignature() throws {
        
        try XCTAssertThrowsAsNSError(
            makeRequest(signatureValue: .init()),
            error: URLRequestFactory.Service.Error.processPublicKeyAuthenticationRequestEmptySignature
        )
    }
    
    func test_makeRequest_shouldSetRequestURL() throws {
        
        let request = try makeRequest()
        
        XCTAssertEqual(
            request.url?.absoluteString,
            "https://dmz-api-gate-test.forabank.ru/processing/auth/v1/processPublicKeyAuthenticationRequest"
        )
    }
    
    func test_makeRequest_shouldSetRequestMethodToPost() throws {
        
        let request = try makeRequest()
        
        XCTAssertEqual(request.httpMethod, "POST")
    }
    
    func test_makeRequest_shouldSetRequestBody() throws {
        
        let clientPublicKeyRSA = anyData()
        let publicApplicationSessionKey = anyData()
        let signature = anyData()
        let request = try makeRequest(
            clientPublicKeyRSAValue: clientPublicKeyRSA,
            publicApplicationSessionKeyValue: publicApplicationSessionKey,
            signatureValue: signature
        )
        
        let httpBody = try XCTUnwrap(request.httpBody)
        let decodedRequest = try JSONDecoder().decode(
            DecodableRequest.self,
            from: httpBody
        )
        
        XCTAssertNoDiff(
            decodedRequest.dataAsData.clientPublicKeyRSA,
            clientPublicKeyRSA
        )
        XCTAssertNoDiff(
            decodedRequest.dataAsData.publicApplicationSessionKey,
            publicApplicationSessionKey
        )
        XCTAssertNoDiff(
            decodedRequest.dataAsData.signature,
            signature
        )
    }
    
    // MARK: - Helpers
    
    private func makeRequest(
        clientPublicKeyRSAValue: Data = anyData(),
        publicApplicationSessionKeyValue: Data = anyData(),
        signatureValue: Data = anyData()
    ) throws -> URLRequest {
        
        try RequestFactory.makeProcessPublicKeyAuthenticationRequest(
            clientPublicKeyRSA: .init(rawValue: clientPublicKeyRSAValue),
            publicApplicationSessionKey: .init(rawValue: publicApplicationSessionKeyValue),
            signature: .init(rawValue: signatureValue)
        )
    }
    
    private struct DecodableRequest: Decodable {
        
        let clientPublicKeyRSA: String
        let publicApplicationSessionKey: String
        let signature: String
        
        var dataAsData: (
            clientPublicKeyRSA: Data?,
            publicApplicationSessionKey: Data?,
            signature: Data?
        ) {
            (
                .init(base64Encoded: clientPublicKeyRSA, options: .ignoreUnknownCharacters),
                .init(base64Encoded: publicApplicationSessionKey, options: .ignoreUnknownCharacters),
                .init(base64Encoded: signature, options: .ignoreUnknownCharacters)
            )
        }
    }
}
