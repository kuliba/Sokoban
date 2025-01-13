//
//  WrapInJSONTests.swift
//  
//
//  Created by Igor Malyarov on 02.10.2023.
//

@testable import CVVPINServices
import XCTest

final class WrapInJSONTests: XCTestCase {
    
    func test_wrapInJSON_shouldThrowOnSignError() throws {
        
        try XCTAssertThrowsAsNSError(
            wrapInJSON(
                clientPublicKeyRSABase64: "abc",
                pasBase64: "123",
                sign: { _ in throw NSError(domain: "Signing Error", code: -1)}
            ),
            error: NSError(domain: "Signing Error", code: -1)
        )
    }
    
    func test_wrapInJSON() throws {
        
        let wrapped = try wrapInJSON(
            clientPublicKeyRSABase64: "abc",
            pasBase64: "123"
        )
        let decoded = try JSONDecoder().decode(RequestJSON.self, from: wrapped)
        
        XCTAssertEqual(decoded.clientPublicKeyRSA, "abc")
        XCTAssertEqual(decoded.publicApplicationSessionKey, "123")
        
        let signature = Data("abc123".utf8).base64EncodedString()
        XCTAssertEqual(decoded.signature, signature)
    }
    
    // MARK: - Helpers
    
    private func wrapInJSON(
        clientPublicKeyRSABase64: String,
        pasBase64: String,
        sign: @escaping (Data) throws -> Data = { $0 }
    ) throws -> Data {
        
        try KeyExchangeHelper.wrapInJSON(
            clientPublicKeyRSABase64: clientPublicKeyRSABase64,
            publicApplicationSessionKeyBase64: pasBase64,
            signWithClientSecretKey: sign
        )
    }
    
    private struct RequestJSON: Decodable {
        
        let clientPublicKeyRSA: String
        let publicApplicationSessionKey: String
        let signature: String
    }
}
